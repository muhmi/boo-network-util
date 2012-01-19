namespace NetworkUtil

import System.IO
import System.Runtime.Serialization.Formatters.Binary

enum MessageValueType:
	Int = 1
	Str = 2
	Bool = 3

static class Message:

	def Encode(msg as Hash):

		using stream = MemoryStream(), formatter = BinaryFormatter():

			formatter.Serialize(stream, msg)

			return stream.ToArray()

	def Decode(msg as (byte)):
		return Decode(msg, 0, msg.Length)

	def Decode(msg as (byte), off as int, length as int):

		using stream = MemoryStream(msg, 0, length), formatter = BinaryFormatter():
			
			bag = formatter.Deserialize(stream) cast Hash

			return bag

	def Dump(msg as Hash):

		dump = ""
		for item in msg:
			if dump.Length > 0:
				dump += ","
			dump += "\"$(item.Key)\": \"$(item.Value)\""

		return "{$dump}"

