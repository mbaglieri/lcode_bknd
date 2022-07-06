bcrypt  = require 'bcrypt'
Promise = require 'bluebird'
Sequelize = require 'sequelize'
module.exports = (sequelize, DataTypes) ->
  notes = sequelize.define('notes', {
    id:
      type         : DataTypes.BIGINT
      allowNull    : false
      primaryKey   : true
      autoIncrement: true

    id_user:
      type     : DataTypes.TEXT
      allowNull: true

    notes:
      type     : DataTypes.TEXT
      allowNull: true


    visible:
      type        : DataTypes.BOOLEAN
      allowNull   : false
      defaultValue: true

    createdAt:
      type:DataTypes.DATE 
      defaultValue:  DataTypes.NOW,
      allowNull: false

    updatedAt: 
      type:DataTypes.DATE 
      defaultValue:  DataTypes.NOW,
      allowNull: false,
  }, {
    timestamps: false,
    tableName : 'user',
    classMethods: validPassword: (password, passwd, done, user) ->
      bcrypt.compareSync password, passwd, (err, isMatch) ->
        if isMatch
          done null, user
        else
          done null, false
      return
    ,classMethods: authenticate: (value) ->
      if bcrypt.compareSync(value, @password)
        this
      else
        false

 })