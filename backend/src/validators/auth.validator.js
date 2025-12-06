const Joi = require('joi');

/**
 * Validation schema for user registration
 */
const registerSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Vui lòng nhập email hợp lệ',
      'string.empty': 'Email không được để trống',
      'any.required': 'Email là bắt buộc'
    }),
  
  name: Joi.string()
    .min(1)
    .max(50)
    .required()
    .messages({
      'string.min': 'Tên không được để trống',
      'string.max': 'Tên không được quá 50 ký tự',
      'string.empty': 'Tên không được để trống',
      'any.required': 'Tên là bắt buộc'
    }),
  
  password: Joi.string()
    .min(8)
    .max(16)
    .required()
    .messages({
      'string.min': 'Mật khẩu phải có ít nhất 8 ký tự',
      'string.max': 'Mật khẩu không được quá 16 ký tự',
      'string.empty': 'Mật khẩu không được để trống',
      'any.required': 'Mật khẩu là bắt buộc'
    }),
  
  confirmPassword: Joi.string()
    .valid(Joi.ref('password'))
    .required()
    .messages({
      'any.only': 'Mật khẩu xác nhận không khớp',
      'string.empty': 'Mật khẩu xác nhận không được để trống',
      'any.required': 'Mật khẩu xác nhận là bắt buộc'
    })
});

/**
 * Validation schema for user login
 */
const loginSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Vui lòng nhập email hợp lệ',
      'string.empty': 'Email không được để trống',
      'any.required': 'Email là bắt buộc'
    }),
  
  password: Joi.string()
    .min(8)
    .max(16)
    .required()
    .messages({
      'string.min': 'Mật khẩu phải có ít nhất 8 ký tự',
      'string.max': 'Mật khẩu không được quá 16 ký tự',
      'string.empty': 'Mật khẩu không được để trống',
      'any.required': 'Mật khẩu là bắt buộc'
    })
});

module.exports = {
  registerSchema,
  loginSchema
};

