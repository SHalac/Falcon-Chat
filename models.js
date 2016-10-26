var mongoose = require('mongoose');
var bcrypt = require('bcrypt');
var Schema = mongoose.Schema;
var SALT_WORK_FACTOR = 10;
var db = 'mongodb://halacselim:Jimmer36@ds011883.mlab.com:11883/trumpetdb';
mongoose.connect(db);

// to use our schema, we need to convert our schema into a model.
// pass it to mongoose.model(modelName, schema);
//instance of a model is a document
// QUERY FOR DOCUMENTS by using models find, findById, findOne or where


//*************************************************
//  DEFINE DATA TYPES AND SCHEMAS/MODELS HERE
//*************************************************

var userSchema = new Schema ({
//make sure youve added everything to schema before calling model
name: String,
email: {
	type: String,
	required: true,
	unique: true
},
username: String,
password: String,
status: String,
friends: [String],
conversations: [mongoose.Schema.Types.ObjectId]
});
//
userSchema.pre('save', function(next) {
  var user = this;
  bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
    if (err) {
      console.log("error with salt \n");
      // Pass error back to Mongoose.
      return next(err);
    }
    bcrypt.hash(user.password, salt, function(error, hash) {
      if (error) {
        console.log("error with hash \n");
        return next(error);
      }
      user.password = hash;
      // Here are we done with the bcrypt stuff, so it's time to call `next`
      next();
    });
  });
});
//
var User = mongoose.model('User',userSchema);

var conversationMessageSchema = new Schema({
author: String,
message: String,
time: String
//to: [{type: mongoose.Schema.Types.ObjectId, ref: 'User'}],
//from: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
});

var conversationMessage = mongoose.model('conversationMessage',conversationMessageSchema);

var conversationSchema = new Schema({
persons: [String],
//messages: [{type: mongoose.Schema.Types.ObjectId, ref: 'conversationMessage'}]
messages:  [{
    author : String,
    content : String,
    time: String
     }]
});
var conversation = mongoose.model('conversation',conversationSchema);

//*********************************************************
// DEFINE DATABASE FUNCTIONS FOR MANAGING USERS
// ********************************************************
var findPersonByUser = function findPersonByUser(userFind){ 
	
	console.log("finding user: "+ userFind + "\n")
	User.findOne({'username': userFind},function(err,doc){
		if(err){
			console.log("nothing returned! :(")
		}
			console.log(doc);
	});
}
var addMessage = function addMessage(user1,user2,message){
	conversation.findOne({},function(err,doc){

	});
}
// Adds a new user to the database
var addNew = function addNew(newName,newEmail,newUsername,newPassword,callback){
	console.log("about to add the following: " +newName+"\n");
	var makeNew = new User({
		name: newName, 
		email: newEmail, 
		username: newUsername,
		password: newPassword,
		status: "Online"
	});
	makeNew.save(function(err){
		
			if(callback)
				callback(err);
		
	});
}
//addNew("Fake name2", "fakemail2@fake.com", "fakeuser2", "FakePassr");

var toggleStatus = function toggleStatus(toggleEmail,toggleStatus){
	User.findOne({email: toggleEmail}, function(err,doc){
		if(err){
			console.log("status toggle error!")
		}
		doc.status = toggleStatus;
		doc.save();
		console.log(toggleEmail + " status changed to "+doc.status + " \n");
	});
}

//********************************************
// PUT EXPORTS HERE
//*********************************************
module.exports = {
	User: User,
	addNew: addNew,
	conversationMessage: conversationMessage,
	conversation: conversation
};
// mongoose.model("users").find(.......)