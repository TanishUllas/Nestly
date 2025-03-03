const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const app = express();
app.use(cors({ origin: "*" })); // ✅ Allow all origins
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
      "INSERT INTO users (firstName, lastName, email, password, dob) VALUES ($1, $2, $3, $4, $5) RETURNING *",
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
    res.json({ message: "✅ Login successful", token });
  } catch (error) {
    console.error("🔥 Error in /login:", error);
    res.status(500).json({ message: "❌ Database error", error: error.message });
  }
});

// ✅ Fetch Guards by Gate
app.get("/guards/:gate", async (req, res) => {
  const { gate } = req.params;
  try {
    const guards = await pool.query("SELECT * FROM guards WHERE gate = $1", [gate]);
    res.json(guards.rows);
  } catch (error) {
    console.error("🔥 Error fetching guards:", error);
    res.status(500).json({ message: "❌ Error fetching guards", error: error.message });
  }
});

// ✅ Fetch All Guards
app.get("/guards", async (req, res) => {
  console.log("📜 Fetching all guards...");

  try {
    const result = await pool.query("SELECT * FROM guards ORDER BY gate");

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "❌ No guards found" });
    }

    console.log("✅ Guards fetched successfully!", result.rows);
    res.json(result.rows);
  } catch (error) {
    console.error("🔥 Error fetching guards:", error);
    res.status(500).json({ message: "❌ Error fetching guards", error: error.message });
  }
});

// ✅ Delete a Guard
app.delete("/guards/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const deleteResult = await pool.query("DELETE FROM guards WHERE id = $1", [id]);
    if (deleteResult.rowCount === 0) {
      return res.status(404).json({ message: "❌ Guard not found" });
    }
    res.json({ message: "✅ Guard deleted successfully" });
  } catch (error) {
    console.error("🔥 Error deleting guard:", error);
    res.status(500).json({ message: "❌ Error deleting guard", error: error.message });
  }
});

// ✅ Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
