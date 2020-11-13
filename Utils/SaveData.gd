extends Node

const all_avatars_key: String = "A11"
var current_avatar_key: String


func load(collection: String, key: String = current_avatar_key, user_id: String = ""):
	if user_id == "":
		user_id = SessionManager.session.user_id

	var result: NakamaAPI.ApiStorageObjects = yield(
		SessionManager.client.read_storage_objects_async(
			SessionManager.session, [NakamaStorageObjectId.new(collection, key, user_id)]
		),
		"completed"
	)

	if result.is_exception():
		push_error("Error interpreting JSON!")
		return

	return JSON.parse(result.objects[0].value).result


func save(
	data,
	collection: String,
	key: String = current_avatar_key,
	permission_read: int = 2,
	permission_write: int = 1,
	version: String = ""
):
	yield(
		SessionManager.client.write_storage_objects_async(
			SessionManager.session,
			[
				NakamaWriteStorageObject.new(
					collection, key, permission_read, permission_write, JSON.print(data), version
				)
			]
		),
		"completed"
	)
