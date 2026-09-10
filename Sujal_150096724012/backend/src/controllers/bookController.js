const { db } = require('../config/firebase');
const BookModel = require('../models/bookModel');

const COLLECTION_NAME = 'books';

/**
 * GET /api/books
 * Get all books
 */
const getAllBooks = async (req, res, next) => {
  try {
    const snapshot = await db.collection(COLLECTION_NAME).get();
    const books = [];

    snapshot.forEach((doc) => {
      books.push(BookModel.format(doc.id, doc.data()));
    });

    return res.status(200).json(books);
  } catch (error) {
    return next(error);
  }
};

/**
 * GET /api/books/:id
 * Get a specific book by ID
 */
const getBookById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Book not found' });
    }

    return res.status(200).json(BookModel.format(doc.id, doc.data()));
  } catch (error) {
    return next(error);
  }
};

/**
 * POST /api/books
 * Add a new book
 */
const createBook = async (req, res, next) => {
  try {
    const validation = BookModel.validate(req.body, false);
    if (!validation.isValid) {
      return res.status(400).json({
        error: 'Validation failed',
        details: validation.errors,
      });
    }

    const { isbn } = validation.sanitized;
    if (isbn && isbn.trim() !== '') {
      const existingSnapshot = await db
        .collection(COLLECTION_NAME)
        .where('isbn', '==', isbn.trim())
        .limit(1)
        .get();

      if (!existingSnapshot.empty) {
        return res.status(409).json({
          error: 'A book with this ISBN already exists',
        });
      }
    }

    const docRef = await db.collection(COLLECTION_NAME).add(validation.sanitized);
    const createdDoc = await docRef.get();

    return res.status(201).json(BookModel.format(createdDoc.id, createdDoc.data()));
  } catch (error) {
    return next(error);
  }
};

/**
 * PUT /api/books/:id
 * Update a book
 */
const updateBook = async (req, res, next) => {
  try {
    const { id } = req.params;
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Book not found' });
    }

    const validation = BookModel.validate(req.body, true);
    if (!validation.isValid) {
      return res.status(400).json({
        error: 'Validation failed',
        details: validation.errors,
      });
    }

    const { isbn } = validation.sanitized;
    if (isbn && isbn.trim() !== '') {
      const existingSnapshot = await db
        .collection(COLLECTION_NAME)
        .where('isbn', '==', isbn.trim())
        .get();

      const duplicate = existingSnapshot.docs.find((d) => d.id !== id);
      if (duplicate) {
        return res.status(409).json({
          error: 'A book with this ISBN already exists',
        });
      }
    }

    await docRef.update(validation.sanitized);
    const updatedDoc = await docRef.get();

    return res.status(200).json(BookModel.format(updatedDoc.id, updatedDoc.data()));
  } catch (error) {
    return next(error);
  }
};

/**
 * DELETE /api/books/:id
 * Delete a book
 */
const deleteBook = async (req, res, next) => {
  try {
    const { id } = req.params;
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Book not found' });
    }

    await docRef.delete();
    return res.status(200).json({
      message: 'Book deleted successfully',
      id,
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getAllBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook,
};
