# Change Log
All notable changes in this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Ongoing changes
subscription qtask:
	find plans to deactivate (ONETIM)
	find plans to create (RESERVE)
	find plans to renew (MONTHLY|YEAR)
disable posibility to buy plans of onetime
execute spells for clean requests
execute spells for clean tables_log
 
batch on create attach plans to stripe | paypal
batch sync plans products offers cupons

- payments ok
	realtime
	scheduled
- subscriptions 
	plans
	txs
	monthly
	one-time
	credits
	quota

- notifications (base system -> falta ref merchant )
	system X
	merchant
		reseller
		(others - no code)

- networks
	network
	community
	environment

- merchant
	account
	resellers
	events
	market
- aaarrr
	users         
	awareness     
	acquisitions  
	activations   
	retentions    
	revenues      
	referrals 
	    
- analytics
	merchant      
	aaarrr        
	networks      
	notifications 
	payments      
	qtask         
	subscriptions 

- integrations
	aws
	azure
	google
	airtable
	zappier
	paypal
	stripe
	
- ebitda
	earnings

### Added
- Updated config + .env
- Added email config with a basic template 
- Added services for HttpRequests + Task Management + ACL
- api:
- acl   OK
	system       
	firebase     
	token        
	me           
	me_val       
	firebase     
	verification 
	devices      
- qtask     OK
	user   
	system 

### Fixed
### Changed