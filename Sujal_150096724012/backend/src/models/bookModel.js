/**
 * Book model definition and validation
 */

class BookModel {
  /**
   * Validate and sanitize book payload
   * @param {Object} data 
   * @param {boolean} isUpdate 
   * @returns {{ isValid: boolean, errors: string[], sanitized: Object }}
   */
  static validate(data, isUpdate = false) {
    const errors = [];
    const sanitized = {};

    if (!isUpdate || data.title !== undefined) {
      if (!data.title || typeof data.title !== 'string' || data.title.trim() === '') {
        errors.push('Title is required and must be a non-empty string.');
      } else {
        sanitized.title = data.title.trim();
      }
    }

    if (!isUpdate || data.author !== undefined) {
      if (!data.author || typeof data.author !== 'string' || data.author.trim() === '') {
        errors.push('Author is required and must be a non-empty string.');
      } else {
        sanitized.author = data.author.trim();
      }
    }

    if (data.isbn !== undefined) {
      sanitized.isbn = typeof data.isbn === 'string' ? data.isbn.trim() : String(data.isbn || '');
    } else if (!isUpdate) {
      sanitized.isbn = '';
    }

    if (data.genre !== undefined) {
      sanitized.genre = typeof data.genre === 'string' ? data.genre.trim() : '';
    } else if (!isUpdate) {
      sanitized.genre = '';
    }

    if (data.price !== undefined) {
      const parsedPrice = parseFloat(data.price);
      if (isNaN(parsedPrice) || parsedPrice < 0) {
        errors.push('Price must be a non-negative number.');
      } else {
        sanitized.price = parsedPrice;
      }
    } else if (!isUpdate) {
      sanitized.price = 0.0;
    }

    if (data.quantity !== undefined) {
      const parsedQuantity = parseInt(data.quantity, 10);
      if (isNaN(parsedQuantity) || parsedQuantity < 0) {
        errors.push('Quantity must be a non-negative integer.');
      } else {
        sanitized.quantity = parsedQuantity;
      }
    } else if (!isUpdate) {
      sanitized.quantity = 0;
    }

    if (data.description !== undefined) {
      sanitized.description = typeof data.description === 'string' ? data.description.trim() : '';
    } else if (!isUpdate) {
      sanitized.description = '';
    }

    if (data.publisher !== undefined) {
      sanitized.publisher = typeof data.publisher === 'string' ? data.publisher.trim() : '';
    } else if (!isUpdate) {
      sanitized.publisher = '';
    }

    if (data.publishedDate !== undefined) {
      const dateVal = new Date(data.publishedDate);
      if (isNaN(dateVal.getTime())) {
        errors.push('Published date must be a valid date.');
      } else {
        sanitized.publishedDate = dateVal.toISOString();
      }
    } else if (!isUpdate) {
      sanitized.publishedDate = new Date().toISOString();
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized,
    };
  }

  /**
   * Format Firestore document data into standard Book response
   * @param {string} id 
   * @param {Object} data 
   * @returns {Object}
   */
  static format(id, data) {
    let publishedDateStr = data.publishedDate;
    if (data.publishedDate && typeof data.publishedDate.toDate === 'function') {
      publishedDateStr = data.publishedDate.toDate().toISOString();
    } else if (data.publishedDate instanceof Date) {
      publishedDateStr = data.publishedDate.toISOString();
    }

    return {
      id: id,
      title: data.title || '',
      author: data.author || '',
      isbn: data.isbn || '',
      genre: data.genre || '',
      price: typeof data.price === 'number' ? data.price : parseFloat(data.price) || 0.0,
      quantity: typeof data.quantity === 'number' ? data.quantity : parseInt(data.quantity, 10) || 0,
      description: data.description || '',
      publisher: data.publisher || '',
      publishedDate: publishedDateStr || new Date().toISOString(),
    };
  }
}

module.exports = BookModel;
