const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
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
  console.log("🟡 Fetching user with ID:", id); // ✅ Debugging

  try {
    const result = await pool.query(
      "SELECT id, firstName, lastName, email, dob FROM users WHERE id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      console.log("❌ User not found in DB for ID:", id); // ✅ Debugging
      return res.status(404).json({ message: "❌ User not found" });
    }

    console.log("✅ User found:", result.rows[0]); // ✅ Debugging
    res.json(result.rows[0]);
  } catch (error) {
    console.error("🔥 Error fetching user:", error);
    res.status(500).json({ message: "❌ Error fetching user", error: error.message });
  }
});

// ✅ Update User Profile
app.put("/users/:id", async (req, res) => {
  const { id } = req.params;
  const { firstName, lastName, dob } = req.body;
  const authHeader = req.headers.authorization;

  // ✅ Ensure Authorization Header Exists
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "❌ Unauthorized: No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    // ✅ Verify JWT Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.id != id) {
      return res.status(403).json({ message: "❌ Forbidden: You cannot update this user" });
    }

    // ✅ Perform Update in Database
    const result = await pool.query(
      "UPDATE users SET firstname = $1, lastname = $2, dob = $3 WHERE id = $4 RETURNING id, firstname, lastname, email, dob",
      [firstName, lastName, dob, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "❌ User not found" });
    }

    res.json({ message: "✅ Profile updated successfully", user: result.rows[0] });
  } catch (error) {
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

// ✅ Start Server
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
