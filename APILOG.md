# API LOG
All notable changes in this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## TODO
# TODO: IMPLEMENT KYC
# TODO: REVIEW CREATE_USER_WITHOUT_SMS
# TODO: PROCESS PAYMENT
# TODO: ADD NOTIFICATION AARRR
# TODO: CREATE CRUD
# TODO: REQUEST API NO_CODE
# TODO: ADD ANALYTICS OF
# TODO: CREATE ALGORITHMS
## Ongoing changes
- ACL 
- DRAGONFLY ALTERNATIVE REDIS https://github.com/dragonflydb/dragonfly/pulls
### Added
public
- [  GET   ] acl/login login user with get
- [  POST  ] acl/login  login user with post
- [  PUT   ] acl/login  login guest user (for contact o pre sale use the ip of the user for create it )
- [  POST  ] acl/register register a user without sending message could be useful for bulk users when is a corporate account or when we want to add multiple users at the same time without expending sms to it
- [  PUT   ] acl/register register a user with sms verification

- [  POST  ] acl/validate resend code  [email]
- [  PUT   ] acl/validate verify the code sent to your device [email, phone]
- [ DELETE ] acl/validate change the device and send a new code [email, phone]


- [  POST  ] acl/forgot forgot user send to verified device the code [email]
- [  PUT   ] acl/forgot verify the code and change the passwrd (and close sessions) [id, code, password, force_close_sessions]

logged
- [  GET   ] /api/me get the user data 


### Fixed
### Changed