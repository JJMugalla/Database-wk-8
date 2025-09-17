# Database-wk-8
'll create a comprehensive Library Management System database schema for Question 1.

his database schema includes:

Entities: Authors, Publishers, Books, Members, Loans, Reservations, and Fines

Relationships:

One-to-Many: Author to Books, Publisher to Books

One-to-Many: Member to Loans, Member to Reservations, Member to Fines

One-to-Many: Book to Loans, Book to Reservations

Constraints:

Primary Keys on all tables

Foreign Keys to maintain referential integrity

Unique constraints on ISBN, email, and publisher name

Check constraints to ensure data validity

Default values and timestamps

Additional Features:

Indexes for performance optimization

Triggers to automatically update available book copies

Comprehensive data tracking with created/updated timestamps

This schema supports all essential library operations including book lending, returns, reservations, and fine management.
