/*******************************************************************************
*	Integration Test for /cfmongodb/models/ActiveEntity.cfc
*******************************************************************************/
component name="TestMongoUtil" extends="testbox.system.BaseSpec"{
	property name="MongoUtil" inject="MongoUtil@cbmongodb";
	property name="MongoClient" inject="MongoClient@cbmongodb";

	function beforeAll(){
		//custom methods
		application.wirebox = new coldbox.system.ioc.Injector('cbmongodb.tests.config.Wirebox');
		application.wirebox.autowire(this);
		expect(isNull(MongoUtil)).toBeFalse("Autowiring Failed!");

	}

	function afterAll(){
		  MongoClient.close();
          structDelete( application, "wirebox" );
	}

	function run(testResults, testBox){

		describe("Test Collection CRUD Methods",function(){
			it("Begins the insert tests",function(){
				//drop our collection, if it exists, and recreate
				MongoClient.getDBCollection("MongoCollectionOperations").drop();
				variables.Collection = MongoClient.getDBCollection("MongoCollectionOperations");
				var testDocs = [];

				for(i=1;i <= 1000;i=i+1){
					arrayAppend(
						testDocs,
						{"iteration":i,"date":javacast('java.util.Date',now()),"boolean": javacast('boolean',i-i),"textString":"I am record number #i# in the collection"}
					);
				}
				
				describe("Tests Collection Insert Methods",function(){
					it("tests insertMany()",function(){
						var bulkInsert = variables.Collection.insertMany(duplicate(testDocs));
						variables.bulkInsert = bulkInsert;
						expect(arrayLen(bulkInsert)).toBe(1000);
						expect(bulkInsert[1]).toHaveKey('_id');
						expect(variables.Collection.count()).toBe(1000);
					});
					it("tests insertOne()",function(){
						var singleInsert = variables.Collection.insertOne(testDocs[1]);
						expect(singleInsert).toHaveKey('_id');
						expect(variables.Collection.count()).toBe(1001);
					});
					it("tests bulkWriteMethod()",function(){
						//TODO:Implement
					});
					it("tests save() method with upsert",function(){
						var upsertInsert = variables.Collection.save(testDocs[2],true);
						expect(upsertInsert).toHaveKey("_id");
						expect(upsertInsert).toHaveKey("date");
						expect(isDate(upsertInsert['date'])).toBeTrue();
						expect(variables.Collection.count()).toBe(1002);
					});
				});

				describe("Tests Collection Query Methods",function(){
					it("tests counting functions",function(){
						//Not Implemented: These are already tested in creation
					});

					it("tests finding methods",function(){
						var testRecord = bulkInsert[1];
						expect(isNull( variables.collection.findById(testRecord['_id'].toString()) )).toBeFalse();
						var emptyResult = variables.collection.find({"iteration":2000});
						expect(emptyResult).toBeStruct();
						expect(structKeyExists(emptyResult,'asArray')).toBeTrue();
						expect(structKeyExists(emptyResult,'asCursor')).toBeTrue();
						expect(structKeyExists(emptyResult,'getResult')).toBeTrue();
						expect(structKeyExists(emptyResult,'asJSON')).toBeTrue();

						expect(arrayLen(emptyResult.asArray())).toBe(0);
						expect(emptyResult.asJSON()).toBeTypeOf('string');
						expect(deSerializeJSON(emptyResult.asJSON())).toBeArray();
						expect(getMetaData(emptyResult.asCursor()).getName()).toBe('com.mongodb.MongoBatchCursorAdapter');
						expect(emptyResult.asCursor().hasNext()).toBeFalse();

						var singleResult = variables.collection.find({"iteration":500});
						expect(arrayLen(singleResult.asArray())).toBe(1);

						var doubleResult = variables.collection.find({"iteration":1});
						expect(arrayLen(doubleResult.asArray())).toBe(2);

					});

					xit("tests distinct()",function(){

						//Test skipped due to casting errors when running against the driver
						var distinctIteration = variables.Collection.distinct("iteration");

					});

					it("tests aggregate()",function(){
						var agMatch={"iteration":{"$lte":500}};
						var agGroup={"_id":"$iteration","iterableSum":{"$sum":"$iteration"}};
						var agSort={"_id":-1};
						var aggregation = variables.Collection.aggregate(
							criteria=agMatch,
							group=agGroup,
							sort=agSort
							);
						expect(arrayLen(aggregation.asArray())).toBe(500);
						//there are two records with an iteration of 1
						expect(aggregation.asArray()[1]['iterableSum']).toBe(500,"the correct sort is not being applied in aggregate()");

						//Now test the straight up command and expect the same results 
						var agCommand = variables.Collection.aggregation(
							[
								{"$match":agMatch},
								{"$group":agGroup},
								{"$sort":agSort}
							]
						);
						expect(arrayLen(agCommand.asArray())).toBe(500);
						expect(agCommand.asArray()[1]['iterableSum']).toBe(500,"the correct sort is not being applied in aggregation()");

					});

					it("tests map reduction",function(){
						
						var map="function(){if(this.iteration <= 2) emit(this._id,this.iteration)}";
						var reduce = "function(key,iterations){return Array.sum(iterations)}";
						var reduction = variables.Collection.mapReduce(map,reduce);

						expect(arrayLen(reduction.asArray())).toBe(4);
						expect(reduction.asCursor().next()['value']).toBe(1);

					});

				});

				describe("Tests Collection Update Methods",function(){
					
				});

				describe("Tests Collection Deletion Methods",function(){
					
				});

				describe( "Tests Collection General Operation Methods", function(){
					
					it("tests renameCollection()",function(){
						
					});
					
				});
			});

		});

		
	}

}