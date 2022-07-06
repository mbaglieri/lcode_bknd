Promise = require 'bluebird'
moment  = require 'moment'
{ body,query } = require('express-validator')


@create_user = (req) ->
  return [ 
    body('username', 'userName doesnt exists').exists(),
    body('email', 'Invalid email').exists().isEmail(),
    body('phone').optional().isInt(),
    body('status').optional().isIn(['enabled', 'disabled']),
    body('password').isLength({ min: 5 }),
    body('passwordConfirmation').custom (value, { req }) -> 
      if!(value is req.body.password)
        throw new Error('Password confirmation does not match password')

      return true;
    
  ]   

@login = (req) ->
  return [ 
    query('username', 'userName doesnt exists').exists().isEmail(),
    query('password', 'Invalid email').exists()
  ]
# param('id').customSanitizer(value => {
#     return ObjectId(value);
#   })
  # [
  #     query('title')
  #         .isString().withMessage('Only letters and digits allowed in title.')
  #         .trim()
  #         .isLength({min: 3}).withMessage('Title too short. Enter a longer title!'),
  #     query('price', 'Enter a valid price.')
  #         .isFloat(),
  #     query('description')
  #         .trim()
  #         .isLength({min: 30, max: 600}).withMessage('Description must be of minimum 30 and maximum 600 characters!'),
  # ]
