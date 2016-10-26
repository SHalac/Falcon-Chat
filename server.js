//var PORT= process.env.PORT || 3000;
//var PORT= process.env.PORT;
var PORT= 3000
var bcrypt = require('bcrypt');
var mongooseLogic = require('./models'); // ./
var user = mongooseLogic.User;
var Conversation = mongooseLogic.conversation;
var ConversationMessage = mongooseLogic.conversationMessage
var addNew = mongooseLogic.addNew;
var bodyParser = require('body-parser');
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var online = 0;
var socketArray = {};
var onlineArray = {};

app.use(bodyParser.json()); 
// mongoose.model("users").find(.......)
app.post('/createuser', function(req, res){
	addNew(req.body.name,req.body.email,req.body.username,req.body.password,function(err){
		if(err){
			console.log('there was an error adding the user...');
			res.send({success:false});
		}
		else{
			res.send({success:true});
			onlineArray[req.body.username] = "offline"
			console.log('success adding user\n');
		}
	});
});


app.post('/populateMessages', function(req,res){
	var parties = req.body.parties;
	parties.sort();
	Conversation.findOne({'persons': parties}, function(err, doc){
		if(err){
			console.log("Error: couldnt find conversation messages");
		}
		var resjson = {
		messageList: doc.messages
		}
		res.send(resjson);
	});

});
app.post('/addFriend', function(req,res){
var adder = req.body.adder;
var toadd = req.body.toadd;
		user.findOne({ 'username': adder}, function (erro, doc){
			if(doc.friends.indexOf(toadd) == -1){
				user.findOneAndUpdate({'username': toadd}, {$push: {friends: adder} }, {new: false}, function (err, friends) {
					console.log("updating "+ toadd + "\n");
					var convArray = [adder,toadd];
					convArray.sort();
						var makeNewConvo = new Conversation({
							persons: convArray,
							messages: []
						});
						makeNewConvo.save(function(err){
						if(err){
							console.log("there was an error saving the convo \n");
						}
						});

					if(err){
					console.log("first find error in add\n");
					}

				user.findOneAndUpdate({'username': adder}, {$push: {friends: toadd} }, {new: false}, function (errs, friendo) {
					console.log("updating "+ adder + "\n");
					if(errs){
					console.log("second find error in add\n");
					res.send({good: false});
					}
					else{
						res.send({good: true});
						}
					});
				});
	}
	else{
		res.send({good:true});
	}
	});
	
});

app.post('/simpleFriendList', function(req,res){
	//console.log("Simple friend list requested\n");
	var resjson = []
	user.findOne({ 'username': req.body.username}, function (err, doc){
		var arrayLength = doc.friends.length;
		var i = 0;
					if(arrayLength !=0){
					doc.friends.forEach(function(docfound){
						var jsontoAdd = {
								username: docfound
								}
							resjson.push(jsontoAdd);
							i++
							if(i == arrayLength){
								//console.log("array is at i:" + i + " .... sending the json \n");
								res.send(resjson);
							}
				
					});
					}
					else{
						res.send([]);
					}
		});
});


app.post('/getFriendList', function(req,res){
	var resjson = []
	user.findOne({ 'username': req.body.username}, function (err, doc){
		var arrayLength = doc.friends.length;
		var i = 0;	
		if(arrayLength != 0){
			//console.log("friend length is not zero! going in.... \n");
			doc.friends.forEach(function(docfound){
				user.findOne({ 'username': docfound}, function (errs, docto){
						var jsontoAdd = {
								username: docto.username,
								name: docto.name,
								status: docto.status
								}
							resjson.push(jsontoAdd);
							i++
							if(i == arrayLength){
							//console.log(resjson);
							res.send(resjson);
							}
						});// find one inside loop
				});// for each loop
		} // check if zero
		else{
			res.send(resjson)
		}
		});// findOne
}); // post request


app.get('/getAll', function(req,res){
	console.log("fetching all the data!\n");
	user.find({}).sort({username: -1}).select('name username').exec(function (err, docs) { 
		if(!err){
			res.send({
				good: true,
				documents: docs
			});
			/*
			docs.forEach(function(docfound){
		console.log(docfound + '\n');
			res.send({
				good: true,
				name: docfound.name,
				user: docfound.username
				});
			});
*/
		}
		else{
			res.send({
				Good: false
			});
		}
	});


});


app.post('/authenticate', function(req,res){
	user.findOne({ 'username': req.body.username}, function (err, doc){
		console.log("about to authenticate with "+ req.body.username + " and "+ req.body.password+ " \n");
		if(err){
			console.log("Could not findOne in Authenticate \n")
		}
		if(doc){
  		bcrypt.compare(req.body.password ,doc.password, function(error,cryptres){
  			if(error){
  				console.log("Could not compare bcrypt in Authenticate.\n")
  			}
  			if(cryptres){
  				res.send({good:true,
  					reason: "password",
  					email: doc.email,
  					name: doc.name,
  					user: doc.username
  				});
  				console.log("Authenticate succesful! \n")
  				}
  			if(!cryptres){
  				res.send({good:false,
				reason: "password"
  				});
  				console.log("Wrong password \n")
  			}
  	});
  	}
  	else{
  		res.send({good:false,
  			reason: "username"
  		});
  		console.log("wrong username...\n");
  	}	
});
});


app.post('/checkEmail',function(req,res){
user.count({'email':req.body.email}, function(err,count){
	console.log("checking email: "+ req.body.email);
	if (count==0){
		res.json({good: true});
	}
	else{
		res.json({good: false});
	}
});
});

app.post('/checkUserName',function(req,res){
user.count({'username':req.body.username}, function(err,count){
	console.log("checking username: "+ req.body.username);
	if (count==0){
		res.json({good: true});
	}
	else{
		res.json({good: false});
	}
});
});

function handleMessage(data){
	console.log("user has sent: " + data);
}

io.on('connection', function(socket){
	online++;
	var connectUser;
	//var testusername = "TESTusername"
	//socket.emit('testSocket', { hello: testusername});
	//socketArray[] no wait actually, it doesnt have username yet.

  console.log('a user connected with socket: ' + socket.id + "\n");
   console.log('TOTAL USERS ONLINE: '+ online + '\n');
 // io.emit("tweet", {text: "hello from the server.js"});
  		socket.on('MessageToServer', function(data) {
    			console.log(data.usernameFROM +" has sent: " + data.message+ " at "+ data.time +"\n");
    			var convoArray = data.usernameTo;
    			convoArray.push(data.usernameFROM);
    			convoArray.sort();
    			var newMsgJson = {
   				 author : data.usernameFROM,
    			content : data.message,
    			time: data.time
     					}
    			Conversation.findOneAndUpdate({'persons': convoArray}, {$push: {messages: newMsgJson} }, {new: false}, function (err, friends) {
    				if(err){
    					console.log("findOneAND UPDATE failed!! \n");
    				}
    				console.log("sockets to update: \n");
    				data.usernameTo.forEach(function(userAlert){

    						if(onlineArray[userAlert] == "online"){
    						console.log("userAler is : "+ userAlert+"\n");
    						var socketLookUp = socketArray[userAlert];
    						io.to(socketLookUp).emit('update', {userToUpdate: data.usernameFROM});
    						} // check if online

    						});
    			}); // find one and update
 					 }); // socket on event

  		socket.on('USERLOGINCHECK',function(data){
  			connectUser = data.username;
  			socketArray[data.username] = socket.id
  			onlineArray[data.username] = "online";
  			//var size = Object.keys(myObj).length;
  			console.log("username connected with socket in dict: "+ socketArray[data.username] + "\n\n");
  		});
  		socket.on('disconnect',function(){
		online--;
		onlineArray[connectUser] = "offline";
		console.log('a user has DISCONNECTED with socket'+ socket.id+ '\n');
		 console.log('TOTAL USERS ONLINE: '+ online + '\n');
				});
});


http.listen(PORT, function(){
  console.log('listening on *:3000');
});



