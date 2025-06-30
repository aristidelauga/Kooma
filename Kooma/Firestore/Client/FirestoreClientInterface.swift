
import Foundation
import FirebaseCore
import Firebase


@MainActor
protocol FirestoreClientInterface {
	var database: Firestore { get set }
}

