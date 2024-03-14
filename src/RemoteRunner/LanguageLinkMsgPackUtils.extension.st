Extension { #name : #LanguageLinkMsgPackUtils }

{ #category : #'*RemoteRunner' }
LanguageLinkMsgPackUtils class >> socketBufferSize [
	"Size in bytes for Sockets and SocketStream IO buffers"

	^ 512 * 1024
]
