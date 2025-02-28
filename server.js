const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Connect to PostgreSQL Database
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  ssl: { rejectUnauthorized: false } // Required for Neon.tech
});

pool.connect((err) => {
  if (err) {
    console.error("❌ PostgreSQL Connection Failed:", err);
    return;
  }
  console.log("✅ PostgreSQL Connected...");
});

// ✅ User Registration
app.post("/register", async (req, res) => {
  const { firstName, lastName, email, password, dob } = req.body;

  try {
    // Check if email exists
    const userCheck = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: "Email already registered" });
    }

    // Hash password and save user
    const hashedPassword = bcrypt.hashSync(password, 10);
    await pool.query(
      "INSERT INTO users (firstName, lastName, email, password, dob) VALUES ($1, $2, $3, $4, $5)",
      [firstName, lastName, email, hashedPassword, dob]
    );

    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Database error" });
  }
});

// ✅ User Login
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

    if (userResult.rows.length === 0) {
      return res.status(401).json({ message: "User not found" });
    }

    const user = userResult.rows[0];

    // Check password
    const validPassword = bcrypt.compareSync(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: "Incorrect password" });
    }

    // Generate JWT Token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: "1h" });

    res.json({ message: "Login successful", token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Database error" });
  }
});

// ✅ Fetch All Visitors
app.get("/visitors", async (req, res) => {
  try {
    const visitors = await pool.query("SELECT * FROM visitors");
    res.json(visitors.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching visitors" });
  }
});

// ✅ Add a Visitor
app.post("/visitors", async (req, res) => {
  const { name, relation, reason } = req.body;

  try {
    await pool.query(
      "INSERT INTO visitors (name, relation, reason) VALUES ($1, $2, $3)",
      [name, relation, reason]
    );
    res.status(201).json({ message: "Visitor added successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error adding visitor" });
  }
});

// ✅ Delete a Visitor
app.delete("/visitors/:id", async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query("DELETE FROM visitors WHERE id = $1", [id]);
    res.json({ message: "Visitor deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error deleting visitor" });
  }
});

// ✅ Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
