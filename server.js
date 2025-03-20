const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
const moment = require("moment"); 

require("dotenv").config();

const app = express();
app.use(cors({ origin: "*" }));
app.use(express.json());

// ✅ Log Every Incoming Request
app.use((req, res, next) => {
  console.log(`📥 ${req.method} request to ${req.url}`);
  next();
});

// ✅ PostgreSQL Database Connection
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,
  ssl: { rejectUnauthorized: false },
});

require("dotenv").config(); // Load environment variables

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const sendMail = async (to, subject, text) => {
  if (!to) {
    console.error("🔥 Error: Recipient email is missing!");
    return;
  }

  try {
    let info = await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to, // Ensure this is correctly passed
      subject,
      text,
    });
    console.log("✅ Email sent successfully:", info.response);
  } catch (error) {
    console.error("🔥 Error sending email:", error);
  }
};

// ✅ Root Route Check
app.get("/", (req, res) => {
  res.json({ message: "✅ API is running successfully!" });
});

// ✅ User Registration
app.post("/register", async (req, res) => {
  const { firstName, lastName, email, password, dob } = req.body;
  try {
    const userCheck = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: "❌ Email already registered" });
    }

    const hashedPassword = bcrypt.hashSync(password, 10);
    const newUser = await pool.query(
      "INSERT INTO users (firstName, lastName, email, password, dob) VALUES ($1, $2, $3, $4, $5) RETURNING id, firstName, lastName, email, dob",
      [firstName, lastName, email, hashedPassword, dob]
    );

    res.status(201).json({ message: "✅ User registered successfully", user: newUser.rows[0] });
  } catch (error) {
    console.error("🔥 Error in /register:", error);
    res.status(500).json({ message: "❌ Database error", error: error.message });
  }
});

// ✅ User Login
app.post("/login", async (req, res) => {
  const { email, password } = req.body;
  try {
    const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (userResult.rows.length === 0) {
      return res.status(401).json({ message: "❌ User not found" });
    }

    const user = userResult.rows[0];
    if (!bcrypt.compareSync(password, user.password)) {
      return res.status(401).json({ message: "❌ Incorrect password" });
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: "1h" });

    res.json({ message: "✅ Login successful", token, user });
  } catch (error) {
    console.error("🔥 Error in /login:", error);
    res.status(500).json({ message: "❌ Database error", error: error.message });
  }
});

app.get("/users/:id", async (req, res) => {
  const { id } = req.params;
  console.log("🟡 Fetching user with ID:", id);

  // ✅ Check if Authorization header is present
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ message: "❌ Unauthorized: No token provided" });
  }

  try {
    // ✅ Verify JWT Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.id != id) {
      return res.status(403).json({ message: "❌ Forbidden: You cannot access this profile" });
    }

    // ✅ Ensure ID is an integer
    if (isNaN(id)) {
      return res.status(400).json({ message: "❌ Invalid user ID" });
    }

    // ✅ Fetch user from database
    const result = await pool.query(
      "SELECT id, firstName AS firstname, lastName AS lastname, email, dob FROM users WHERE id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      console.log("❌ User not found in DB for ID:", id);
      return res.status(404).json({ message: "❌ User not found" });
    }

    console.log("✅ User found:", result.rows[0]);
    res.json(result.rows[0]);

  } catch (error) {
    // ✅ Handle JWT errors separately
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({ message: "❌ Invalid token" });
    }
    console.error("🔥 Error fetching user:", error);
    res.status(500).json({ message: "❌ Error fetching user", error: error.message });
  }
});


// ✅ Update User Profile
app.put("/users/:id", async (req, res) => {
  const { id } = req.params;
  let { firstName, lastName, dob, password } = req.body;

  console.log("🟡 Updating user profile: ID=", id);

  // ✅ Check if Authorization header is present
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ message: "❌ Unauthorized: No token provided" });
  }

  try {
    // ✅ Verify JWT Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.id != id) {
      return res.status(403).json({ message: "❌ Forbidden: You cannot update this profile" });
    }

    // ✅ Ensure ID is an integer
    if (isNaN(id)) {
      return res.status(400).json({ message: "❌ Invalid user ID" });
    }

    // ✅ Validate required fields
    if (!firstName || !lastName || !dob) {
      return res.status(400).json({ message: "❌ First name, last name, and DOB are required" });
    }

    // ✅ If password is provided, hash it
    let passwordQuery = "";
    let passwordValues = [];
    if (password && password.length >= 6) {
      const hashedPassword = bcrypt.hashSync(password, 10);
      passwordQuery = ", password = $5";
      passwordValues = [hashedPassword];
    }

    // ✅ Update user profile
    const result = await pool.query(
      `UPDATE users 
       SET firstname = $1, lastname = $2, dob = $3 ${passwordQuery} 
       WHERE id = $4 RETURNING id, firstname AS firstName, lastname AS lastName, email, dob`,
      [firstName, lastName, dob, id, ...passwordValues]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "❌ User not found" });
    }

    console.log("✅ Profile updated successfully:", result.rows[0]);
    res.json({ message: "✅ Profile updated successfully", user: result.rows[0] });

  } catch (error) {
    // ✅ Handle JWT errors separately
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({ message: "❌ Invalid token" });
    }
    console.error("🔥 Error updating user:", error);
    res.status(500).json({ message: "❌ Error updating user", error: error.message });
  }
});

// ✅ Fetch All Guards
app.get("/guards", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM guards ORDER BY gate");
    res.json(result.rows);
  } catch (error) {
    console.error("🔥 Error fetching guards:", error);
    res.status(500).json({ message: "❌ Error fetching guards", error: error.message });
  }
});

// ✅ Delete a Guard
app.delete("/guards/:id", async (req, res) => {
  try {
    const deleteResult = await pool.query("DELETE FROM guards WHERE id = $1", [req.params.id]);
    if (deleteResult.rowCount === 0) {
      return res.status(404).json({ message: "❌ Guard not found" });
    }
    res.json({ message: "✅ Guard deleted successfully" });
  } catch (error) {
    console.error("🔥 Error deleting guard:", error);
    res.status(500).json({ message: "❌ Error deleting guard", error: error.message });
  }
});

// ✅ Fetch All `myvisitors`
app.get("/myvisitors", async (req, res) => {
  try {
    const visitors = await pool.query("SELECT * FROM myvisitors ORDER BY created_at DESC");
    res.json(visitors.rows);
  } catch (error) {
    console.error("🔥 Error fetching myvisitors:", error);
    res.status(500).json({ message: "❌ Error fetching myvisitors", error: error.message });
  }
});

// ✅ Delete a `myvisitor`
app.delete("/myvisitors/:id", async (req, res) => {
  try {
    const deleteResult = await pool.query("DELETE FROM myvisitors WHERE id = $1", [req.params.id]);
    if (deleteResult.rowCount === 0) {
      return res.status(404).json({ message: "❌ My Visitor not found" });
    }
    res.json({ message: "✅ My Visitor deleted successfully" });
  } catch (error) {
    console.error("🔥 Error deleting myvisitor:", error);
    res.status(500).json({ message: "❌ Error deleting myvisitor", error: error.message });
  }
});

app.get("/myvisitors/user/:userId", async (req, res) => {
  const userId = parseInt(req.params.userId, 10);
  console.log(`🟡 Fetching visitors for userId: ${userId}`);

  try {
    if (isNaN(userId)) {
      return res.status(400).json({ message: "❌ Invalid user ID" });
    }

    const result = await pool.query("SELECT * FROM myvisitors WHERE user_id = $1", [userId]);

    if (result.rows.length === 0) {
      console.log("❌ No visitors found for this user");
      return res.status(404).json({ message: "❌ No visitors found for this user" });
    }

    console.log("✅ Visitors found:", result.rows);
    res.json(result.rows);
  } catch (error) {
    console.error("🔥 Error fetching visitors:", error);
    res.status(500).json({ message: "❌ Error fetching visitors", error: error.message });
  }
});

app.post("/myvisitors", async (req, res) => {
  const { userId, name, relation, date, time } = req.body;

  if (!userId || !name || !relation || !date || !time) {
    return res.status(400).json({ message: "❌ Missing required fields" });
  }

  try {
    await pool.query(
      "INSERT INTO myvisitors (user_id, name, relation, date, time) VALUES ($1, $2, $3, $4, $5)",
      [userId, name, relation, date, time]
    );

    res.json({ message: "✅ Visitor added successfully!" });
  } catch (error) {
    console.error("🔥 Error adding visitor:", error);
    res.status(500).json({ message: "❌ Error adding visitor", error: error.message });
  }
});

// ✅ Delete a Visitor
app.delete("/myvisitors/:id", async (req, res) => {
  try {
    const visitorId = req.params.id;
    const deleteResult = await pool.query("DELETE FROM myvisitors WHERE id = $1", [visitorId]);

    if (deleteResult.rowCount === 0) {
      return res.status(404).json({ message: "❌ Visitor not found" });
    }
    res.json({ message: "✅ Visitor deleted successfully" });
  } catch (error) {
    console.error("🔥 Error deleting visitor:", error);
    res.status(500).json({ message: "❌ Error deleting visitor", error: error.message });
  }
});

app.post("/pre-approve", async (req, res) => {
  let { userId, type, name, relation, date, time } = req.body;

  // ✅ Ensure Name and Relation are `null` if Empty
  name = name?.trim() || null;
  relation = relation?.trim() || null;

  // ✅ Convert "Today" and "Tomorrow" to Exact Date
  if (date === "Today") {
    date = moment().format("YYYY-MM-DD"); // ✅ Today's Date
  } else if (date === "Tomorrow") {
    date = moment().add(1, "days").format("YYYY-MM-DD"); // ✅ Tomorrow's Date
  }

  // ✅ Basic Validation
  if (!userId || !type || !date || !time) {
    return res.status(400).json({ message: "❌ Missing required fields" });
  }

  try {
    const result = await pool.query(
      "INSERT INTO pre_approvals (user_id, type, name, relation, date, time) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *",
      [userId, type, name, relation, date, time]
    );

    res.json({ message: "✅ Pre-approval added successfully!", data: result.rows[0] });
  } catch (error) {
    console.error("🔥 Error in pre-approval:", error);
    res.status(500).json({ message: "❌ Error adding pre-approval", error: error.message });
  }
});

app.post("/visitors/add", async (req, res) => {
  const { host_name, name, relation, reason } = req.body;

  if (!host_name || !name || !relation || !reason) {
    return res.status(400).json({ message: "❌ Missing required fields" });
  }

  try {
    // ✅ Find user_id from host_name
    const userQuery = await pool.query(
      "SELECT id FROM users WHERE firstName || ' ' || lastName = $1",
      [host_name]
    );

    if (userQuery.rows.length === 0) {
      return res.status(404).json({ message: "❌ Host not found" });
    }

    const userId = userQuery.rows[0].id;

    // ✅ Insert visitor request with mapped user_id
    const result = await pool.query(
      "INSERT INTO visitors (host_name, user_id, name, relation, reason, arrival_time, status) VALUES ($1, $2, $3, $4, $5, NOW(), 'Pending') RETURNING *",
      [host_name, userId, name, relation, reason]
    );

    res.json({ message: "✅ Visitor added successfully!", data: result.rows[0] });
  } catch (error) {
    console.error("🔥 Error adding visitor:", error);
    res.status(500).json({ message: "❌ Error adding visitor", error: error.message });
  }
});

app.get('/visitors', async (req, res) => {
  try {
      const result = await pool.query("SELECT * FROM visitors"); 
      console.log("Query Result:", result.rows); // Debugging output

      res.json(result.rows); // Use result.rows for PostgreSQL
  } catch (error) {
      console.error("Error fetching visitors:", error);
      res.status(500).json({ error: error.message });
  }
});

app.get("/visitors/:host_name", async (req, res) => {
  const hostName = req.params.host_name;
  console.log(`🟡 Fetching visitors for host: ${hostName}`);

  try {
    // ✅ Find user_id for the given host name
    const userQuery = await pool.query(
      "SELECT id FROM users WHERE firstName || ' ' || lastName = $1",
      [hostName]
    );

    if (userQuery.rows.length === 0) {
      return res.status(404).json({ message: "❌ Host not found" });
    }

    const userId = userQuery.rows[0].id;

    // ✅ Fetch visitors for this user
    const result = await pool.query(
      "SELECT * FROM visitors WHERE user_id = $1 AND arrival_time >= NOW() - INTERVAL '10 minutes' AND status = 'Pending'",
      [userId]
    );

    if (result.rows.length === 0) {
      console.log("❌ No recent visitors found");
      return res.status(404).json({ message: "❌ No recent visitors found" });
    }

    console.log("✅ Visitors found:", result.rows);
    res.json(result.rows);
  } catch (error) {
    console.error("🔥 Error fetching visitors:", error);
    res.status(500).json({ message: "❌ Error fetching visitors", error: error.message });
  }
});

app.get('/visitors/recent/:userId', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId); // Ensure it's an integer

    const result = await pool.query(
      `SELECT * FROM visitors 
       WHERE user_id = $1 
       AND arrival_time >= NOW() - INTERVAL '10 minutes'
       AND status = 'Pending'
       ORDER BY arrival_time DESC`,
      [userId]
    );

    res.json(result.rows); // PostgreSQL returns data inside `result.rows`
  } catch (error) {
    console.error("🔥 Error fetching recent visitors:", error);
    res.status(500).json({ error: error.message });
  }
});

app.put("/visitors/:id/status", async (req, res) => {
  const { status, addToMyVisitors } = req.body; // 'Accepted', 'Rejected' + optional flag for adding

  const visitorId = req.params.id;

  if (status !== "Accepted" && status !== "Rejected") {
    return res.status(400).json({ message: "❌ Invalid status value" });
  }

  try {
    // ✅ Update visitor status in `visitors` table
    const result = await pool.query(
      "UPDATE visitors SET status = $1 WHERE id = $2 RETURNING *",
      [status, visitorId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "❌ Visitor not found" });
    }

    const visitor = result.rows[0];

    // ✅ If Accept & Add button is clicked, add to `myvisitors`
    if (status === "Accepted" && addToMyVisitors) {
      await pool.query(
        "INSERT INTO myvisitors (user_id, name, category, created_at) VALUES ($1, $2, $3, NOW())",
        [visitor.user_id, visitor.name, visitor.category] // ✅ Use `category` instead of `relation`
      );
    }

    res.json({ message: `✅ Visitor ${status} successfully!`, visitor });
  } catch (error) {
    console.error("🔥 Error updating visitor status:", error);
    res.status(500).json({ message: "❌ Error updating visitor status", error: error.message });
  }
});

app.post("/myvisitors/add", async (req, res) => {
  const { user_id, name, category } = req.body; // ✅ Ensure 'category' is used
  try {
    const result = await pool.query(
      "INSERT INTO myvisitors (user_id, name, category) VALUES ($1, $2, $3) RETURNING *",
      [user_id, name, category]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error("❌ Error adding visitor:", error);
    res.status(500).json({ message: "Error adding visitor", error: error.message });
  }
});

app.post("/send-email", async (req, res) => {
  const { subject, message } = req.body;

  if (!subject || !message) {
    return res.status(400).json({ message: "❌ Subject and message required" });
  }

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: "nestlyindia@gmail.com", 
    subject: subject,
    text: message,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log("✅ Email Sent:", info.response);
    res.status(200).json({ message: "✅ SOS alert sent successfully" });
  } catch (error) {
    console.error("🔥 Error sending email:", error);
    res.status(500).json({ message: "❌ Failed to send email", error: error.toString() });
  }
});

// ✅ Start Server
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
