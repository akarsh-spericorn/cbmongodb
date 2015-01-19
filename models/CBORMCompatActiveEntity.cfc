component extends="cbmongodb.models.VirtualEntityService"{
	/************************************ CBORM Compat VES Methods********************************/ 
	any function list(struct criteria=get_criteria(),keys=get_keys(),numeric offset=get_offset(),numeric limit=get_limit(),any sort=get_sort(),boolean asQuery=getDefaultAsQuery()){
		 results=this.query(argumentCollection=arguments);
		 if(arguments.asQuery()){
		 	results=this.convertToQuery(results);
		 }
		 return results;
	}
	

	any function findWhere(required struct criteria){
		this.set_criteria(arguments.criteria);
		return this.query();
	}

	array function findAllWhere(required struct criteria, string sortOrder=""){
		this.set_criteria(arguments.criteria);
		if(len(arguments.SortOrder)){
			var sort=listToArray(arguments.sortOrder,' ');
			var
			this.setSort({sort[1]=sort[2]});	
		}
		return this.query();
	}

	
	//TODO: Figure
	any function new(struct properties=structnew(), boolean composeRelationships=true, nullEmptyInclude="", nullEmptyExclude="", boolean ignoreEmpty=false, include="", exclude=""){
		
	}

	
	boolean function exists(required any id) {
		arguments.entityName = this.getEntityName();
		return super.exists(argumentCollection=arguments);
	}

	any function get(required any id,boolean returnNew=true) {
		arguments.entityName = this.getEntityName();
		return super.get(argumentCollection=arguments);
	}

	array function getAll(any id,string sortOrder="") {
		arguments.entityName = this.getEntityName();
		return super.getAll(argumentCollection=arguments);
	}

	numeric function deleteAll(boolean flush=false,boolean transactional=getUseTransactions()){
		arguments.entityName = this.getEntityName();
		return super.deleteAll(arguments.entityName,arguments.flush);
	}

	boolean function deleteByID(required any id, boolean flush=false,boolean transactional=getUseTransactions()){
		arguments.entityName = this.getEntityName();
		return super.deleteByID(argumentCollection=arguments);
	}

	any function deleteByQuery(required string query, any params, numeric max=0, numeric offset=0, boolean flush=false, boolean transactional=getUseTransactions() ){
		arguments.datasource = this.getDatasource();
		return super.deleteByQuery(argumentCollection=arguments);
	}

	numeric function deleteWhere(boolean transactional=getUseTransactions()){
		arguments.entityName = this.getEntityName();
		return super.deleteWhere(argumentCollection=arguments);
	}

	numeric function count(string where="", any params=structNew()){
		arguments.entityName = this.getEntityName();
		return super.count(argumentCollection=arguments);
	}

	numeric function countWhere(){
		arguments.entityName = this.getEntityName();
		return super.countWhere(argumentCollection=arguments);
	}

	void function evict(string collectionName, any id){
		arguments.entityName = this.getEntityName();
		super.evict(argumentCollection=arguments);
	}

	any function clear(string datasource=this.getDatasource()){
		return super.clear(argumentCollection=arguments);
	}

	boolean function isSessionDirty(string datasource=this.getDatasource()){
		arguments.datasource = this.getDatasource();
		return super.isSessionDirty(argumentCollection=arguments);
	}

	struct function getSessionStatistics(string datasource=this.getDatasource()){
		arguments.datasource = this.getDatasource();
		return super.getSessionStatistics(argumentCollection=arguments);
	}

	string function getKey(){
		return super.getKey( this.getEntityName() );
	}

	array function getPropertyNames(){
		return super.getPropertyNames(this.getEntityName());
	}

	string function getCollectionName(){
		return this.getCollection());
	}
}