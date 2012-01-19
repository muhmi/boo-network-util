namespace NetworkUtil

import System.IO;

enum MessageValueType:
	Int = 1
	Str = 2
	Bool = 3

static class Message:

	def Encode(msg as Hash):

		using stream = MemoryStream(), writer = BinaryWriter(stream):

			writer.Write(msg.Count cast int)

			for item in msg:

				writer.Write(item.Key as string)

				if item.Value isa int:
					writer.Write(MessageValueType.Int cast int)
					writer.Write(item.Value cast int)
				elif item.Value isa string or item.Value isa System.String:
					writer.Write(MessageValueType.Str cast int)
					writer.Write(item.Value as string)
				elif item.Value isa bool:
					writer.Write(MessageValueType.Bool cast int)
					writer.Write(item.Value cast bool)
				else:
					raise "Type: " + item.Value.GetType() + " is not supported!"

			writer.Close()

			return stream.ToArray()

	def Decode(msg as (byte)):
		return Decode(msg, 0, msg.Length)

	def Decode(msg as (byte), off as int, length as int):

		using reader = BinaryReader(MemoryStream(msg, 0, length)):

			items = reader.ReadInt32()

			bag = {}

			for i in range(0, items):

				key = reader.ReadString()
				typ = reader.ReadInt32()

				if typ == MessageValueType.Int:
					bag[key] = reader.ReadInt32()
				elif typ == MessageValueType.Str:
					bag[key] = reader.ReadString()
				elif typ == MessageValueType.Bool:
					bag[key] = reader.ReadBoolean()
				else:
					raise "Message value type " + typ + " is not supported!"

			return bag

	def Dump(msg as Hash):

		dump = ""
		for item in msg:
			if dump.Length > 0:
				dump += ","
			dump += "\"$(item.Key)\": \"$(item.Value)\""

		return "{$dump}"

