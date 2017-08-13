const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const stripe = require('stripe')(functions.config().stripe.testkey);

const price = {"1000": 10, "3000": 30, "6000": 60, "11900": 120};

exports.stripeCharge = functions.database
								.ref('/users/{userId}/payments/charges/{id}')
								.onWrite(event => {
									console.log('wirte triggered');
									const val = event.data.val();
									console.log("what is val");
									console.log(val);

									if (val === null || val.id || val.error) return null;

									return admin.database()
												.ref(`/users/${event.params.userId}/payments/customerId`)
												.once('value')
												.then(snapshot => {
													console.log("user id");
													console.log(event.params.userId);
													return snapshot.val();
												})
												.then(customer => {
													console.log("customer ID");
													console.log(customer);
													const amount = val.amount;
													const idempotency_key = event.params.id;
													const currency = 'cad';
													const charge = {amount, currency, customer};

													console.log('charging the customers...');

													if (val.source !== null) charge.source = val.source;

													return stripe.charges.create(charge, {idempotency_key});
												})

												.then(response => {
													console.log('writing back to db');
													return event.data.adminRef.set(response);			
												});
								});


exports.createStripeUser = functions.auth.user().onCreate(event => {
	const data = event.data;
	console.log("creating a new user!");
	console.log(data);
	return stripe.customers.create().then(customer => {
		console.log("creating stripe customer");
		console.log(customer);
		return admin.database().ref(`/users/${data.uid}/payments/customerId`).set(customer.id);
	});
});


exports.addPaymentToken = functions.database.ref('/users/{userId}/payments/sources/token').onWrite(event => {
	const source = event.data.val();
	console.log("this should be the token");
	console.log(event.data.val());
	console.log("adding new source to customer");
	if (source === null) return null;
	console.log("what is event.params.userId");
	console.log(event.params);
	console.log(event.params.userId);
	return admin.database().ref(`/users/${event.params.userId}/payments/customerId`).once('value')
		   .then(snapshot => {
		   	console.log("snapshot in addPaymentToken");
		   	console.log(snapshot.val());
    return snapshot.val();
	}).then (customer => {
		console.log("customer inside addPaymentTOken");
		console.log(customer);
		console.log("please let this be the token");
		console.log(source);

		return stripe.customers.retrieve(customer);// , function(err, customer) {
			//console.log("GG something went wrong");

  		}).then(customerobj => {
  			console.log("got customer");

			if (customerobj.default_source == null) {
				console.log("whats with the source");
				console.log(source);

				return stripe.customers.createSource(customerobj.id, {source});
			}
			else {
				console.log("updating customer card");

				return stripe.customers.update(customerobj.id, {source});
			}
	}).then(response => {
		console.log("response from addPaymentToken");
		console.log(response);
		return event.data.adminRef.set(response);
	// }, error => {
	// 	return event.data.adminRef.parent.child('error').set(userFacingMessage(error)).then(() => {
	// 		return reportError(error, {user: event.params.userId});
	// 		});
	 	});
	});

exports.updateBalance = functions.database.ref('/users/{sid}/payments/charges/{pid}').onUpdate(event => {
	const sid = event.params.sid;
	const id = event.params.pid;
	const amount = event.data.current.child('amount').val();
	console.log("what is amount");
	console.log(event.data.current.child('amount').val());

	var ref = admin.database().ref("/users/" + sid + "/balance");
	ref.once("value").then(snapshot => {
		console.log("what is snapshot in balance");
		console.log(snapshot.val());
		var currentBalance = snapshot.val();
		// console.log(price);
		let amountString = amount.toString();
		let increment = price[amountString];
		currentBalance += increment;
		console.log(currentBalance);
		ref.set(currentBalance);
	})

})


exports.inactiveQuestion = functions.database.ref('/requests/active/{questionId}/status').onUpdate(event => {
	
	const questionId = event.params.questionId;
	console.log(questionId);
	var ref = admin.database().ref("/requests/active/" + questionId);
	console.log("inactiveQuestion triggered");
	ref.once("value").then(snapshot => {
		var changedQ = snapshot.val();
		console.log("what does it return");
		console.log(snapshot.val());
		console.log("removing node");
		ref.remove().then(function(){
			console.log("add to inactive");
	   		admin.database().ref("/requests/inactive/" + questionId).set(changedQ);
		});
	})
})




