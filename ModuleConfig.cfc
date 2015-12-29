/**
*
* <strong>CFMongoDB Module Configuration</strong>
*
* <p>An Active Entity Module for MongoDB</p>
*
* @author Jon Clausen <jon_clausen@silowebworks.com>
*
* @link https://github.com/jclausen/cbmongodb
*/
component{
	property name="MongoDBConfig";

	// Module Properties
	this.title 				= "CBMongoDB";
	this.author 			= "Jon Clausen";
	this.webURL 			= "http://https://github.com/jclausen/cbmongodb";
	this.description 		= "Coldbox SDK and Virtual Entity Service for MongoDB";
	// Our version changes with the driver version used, only the patch is updated without a full driver updated
	this.version			= "3.2.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= false;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = false;
	// Module Entry Point
	this.entryPoint			= "cbmongodb";
	// Model Namespace to use
	this.modelNamespace		= "cbmongodb";
	// CF Mapping to register
	this.cfmapping			= "cbmongodb";
	// Module Dependencies to be loaded in order
	this.dependencies 		= ['cbjavaloader'];

	/**
	* CBMongoDB Module Registration
	*/
	function configure(){
		//Retrieve our module settings
		parseParentSettings();

		// Layout Settings
		layoutSettings = {noLayout:true};

		// SES Routes
		if(VARIABLES.MongoDBConfig.permitDocs || VARIABLES.MongoDBConfig.permitTests){
			routes = [
				// Module Entry Point
				{ pattern="/", handler="Docs", action="index" },
				// Convention Route
				{ pattern="/:handler/:action?" }
			];	
		}

		//Future Implementation:
		// if(VARIABLES.MongoDBConfig.permitAPI){
		// 	routes = [
		// 		// Module Entry Point
		// 		{ pattern="/api/", handler="api.v1.GenericMongoAPI", action="index" },
		// 		// Convention Route
		// 		{ pattern="/:collection/:action?/:_id?" }
		// 	];	
		// }
	}

	/**
	* CBMongoDB Module Activation - Fires when the module is loaded
	*/
	function onLoad(){
		
		//ensure cbjavaloader is an activated module
		if(!Wirebox.getColdbox().getModuleService().isModuleActive('cbjavaloader')){
			Wirebox.getColdbox().getModuleService().reload('cbjavaloader');	
		}
		
		var modulePath = getDirectoryFromPath(getCurrentTemplatePath());
		var jLoader = Wirebox.getInstance("loader@cbjavaloader");
		jLoader.appendPaths(modulePath & '/lib/');
	 	

		/**
		* Singletons
		**/
		//configuration object
		binder.map("MongoConfig@cbmongodb")
			.to('cbmongodb.models.Mongo.Config')
			.initWith(VARIABLES.MongoDBConfig)
			.asSingleton();

		/**	
		* Utility Classes
		**/

		//models.Mongo.Util
		binder.map("MongoUtil@cbmongodb")
			.to("cbmongodb.models.Mongo.Util")
			.initWith()
			.asSingleton();

		//indexer
		binder.map("MongoIndexer@cbmongodb")
			.to("cbmongodb.models.Mongo.Indexer")
			.asSingleton();

		//models.Mongo.Collection
		binder.map("MongoCollection@cbmongodb")
			.to('cbmongodb.models.Mongo.Collection')
			.noInit();

		/**
		* Mongo Client Singleton
		**/
		binder.map( "MongoClient@cbmongodb" )
			.to( "cbmongodb.models.Mongo.Client" )
			.initArg(name="MongoConfig",ref="MongoConfig@cbmongodb")
			.asSingleton();

		/**
		* DSL Mappings for Our Test Mocks
		**/
		binder.map("People@CBMongoTestMocks").to("cbmongodb.tests.mocks.ActiveEntityMock");
		binder.map("Counties@CBMongoTestMocks").to("cbmongodb.tests.mocks.CountiesMock");
		binder.map("States@CBMongoTestMocks").to("cbmongodb.tests.mocks.StatesMock");
	}

	/**
	* CBMongoDB Module Deactivation - Fired when the module is unloaded
	*/
	function onUnload(){
		if(Wirebox.containsInstance("MongoClient@cbmongodb")){
			Wirebox.getInstance("MongoClient@cbmongodb").close();		
		}
	}

	/**
	* Prepare settings for MongoDB Connections.
	*/
	private function parseParentSettings(){
		var oConfig 			= controller.getSetting( "ColdBoxConfig" );
		var configStruct 		= controller.getConfigSettings();
		var MongoDBSettings		= oConfig.getPropertyMixin( "MongoDB", "variables", {} );

		
		//check if a config has been misplaced within the custom settings structure
		if(structIsEmpty(MongoDbSettings) and structKeyExists(configStruct,"MongoDB")){
			MongoDBSettings = duplicate(configStruct.MongoDB);
		}		
			
		//default config struct
		configStruct.MongoDB = {
			//The default hosts
			hosts		= [
							{
								serverName:'127.0.0.1',
								serverPort:'27017'
							}
							
						  ],
			//the default client options
			clientOptions = {
				//The connection timeout in ms (if omitted, the timeout is 30000ms)
				"connectTimeout":2000
			},
			//The default database
			db 	= "test",
			//whether to permit viewing of the API documentation
			permitDocs = true,
			//whether to permit unit tests to run
			permitTests = true,
			//whether to permit generic API access (future implementation)
			permitAPI = true,
		};

		// Incorporate settings
		structAppend( configStruct.MongoDB, MongoDBSettings, true );

		VARIABLES.MongoDBConfig = configStruct.MongoDB;

	}

}
