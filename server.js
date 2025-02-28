const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const app = express();
app.use(cors({ origin: "*" })); // ✅ Allow all origins for API requests
app.use(express.json());

// ✅ Log Every Incoming Request for Debugging
app.use((req, res, next) => {
  console.log(`📥 ${req.method} request to ${req.url}`);
  next();
});

// ✅ Root Route Check
app.get("/", (req, res) => {
  console.log("✅ GET / was requested!");
  res.json({ message: "✅ API is running successfully!" });
});

// ✅ PostgreSQL Database Connection with Auto-Reconnect
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,
  ssl: { rejectUnauthorized: false },
  max: 10, // ✅ Prevents connection overload
  idleTimeoutMillis: 30000, // ✅ Closes idle connections after 30s
  connectionTimeoutMillis: 5000, // ✅ Timeout if connection takes too long
});

// ✅ Auto-Reconnect on Database Errors
pool.on("error", (err) => {
  console.error("❌ Unexpected Database Error:", err);
  console.log("🔄 Attempting to reconnect in 5 seconds...");
  setTimeout(() => {
    pool.connect().catch((error) => console.error("🔴 Reconnection Failed:", error));
  }, 5000);
});

// ✅ Handle App Shutdown Gracefully
process.on("exit", () => {
  console.log("🛑 Server is shutting down. Closing database connection...");
  pool.end();
});

// ✅ User Registration
app.post("/register", async (req, res) => {
  console.log("📝 Registering user...");
  const { firstName, lastName, email, password, dob } = req.body;

  try {
    const userCheck = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: "❌ Email already registered" });
    }

    const hashedPassword = bcrypt.hashSync(password, 10);
    await pool.query(
      "INSERT INTO users (firstName, lastName, email, password, dob) VALUES ($1, $2, $3, $4, $5)",
      [firstName, lastName, email, hashedPassword, dob]
    );

    res.status(201).json({ message: "✅ User registered successfully" });
  } catch (error) {
    console.error("🔥 Error in /register:", error);
    res.status(500).json({ message: "❌ Database error", error: error.message });
  }
});

// ✅ User Login
app.post("/login", async (req, res) => {
  console.log("🔑 User login attempt...");
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

    const token = jwt.sign(
      { id: user.id || user.email },
      process.env.JWT_SECRET || "defaultsecret",
      { expiresIn: "1h" }
    );

    res.json({ message: "✅ Login successful", token });
  } catch (error) {
    console.error("🔥 Error in /login:", error);
    res.status(500).json({ message: "❌ Database error", error: error.message });
  }
});

// ✅ Fetch All Visitors
app.get("/visitors", async (req, res) => {
  console.log("📜 Fetching all visitors...");
  try {
    const visitors = await pool.query("SELECT * FROM visitors");
    res.json(visitors.rows);
  } catch (error) {
    console.error("🔥 Error fetching visitors:", error);
    res.status(500).json({ message: "❌ Error fetching visitors", error: error.message });
  }
});

// ✅ Add a Visitor
app.post("/visitors", async (req, res) => {
  console.log("➕ Adding a visitor...");
  const { name, relation, reason } = req.body;

  try {
    await pool.query(
      "INSERT INTO visitors (name, relation, reason) VALUES ($1, $2, $3)",
      [name, relation, reason]
    );
    res.status(201).json({ message: "✅ Visitor added successfully" });
  } catch (error) {
    console.error("🔥 Error adding visitor:", error);
    res.status(500).json({ message: "❌ Error adding visitor", error: error.message });
  }
});

// ✅ Delete a Visitor
app.delete("/visitors/:id", async (req, res) => {
  console.log("❌ Deleting a visitor...");
  const { id } = req.params;

  try {
    const deleteResult = await pool.query("DELETE FROM visitors WHERE id = $1", [id]);

    if (deleteResult.rowCount === 0) {
      return res.status(404).json({ message: "❌ Visitor not found" });
    }

    res.json({ message: "✅ Visitor deleted successfully" });
  } catch (error) {
    console.error("🔥 Error deleting visitor:", error);
    res.status(500).json({ message: "❌ Error deleting visitor", error: error.message });
  }
});

// ✅ Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
