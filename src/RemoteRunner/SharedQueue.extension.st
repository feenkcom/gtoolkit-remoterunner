Extension { #name : #SharedQueue }

{ #category : #'*RemoteRunner' }
SharedQueue >> gtRrAsElement [

	^ BrSimpleList new
		  items: self contents;
		  stencil: #asElement;
		  yourself
]

{ #category : #'*RemoteRunner' }
SharedQueue >> gtRrNextSuchThat: aBlock [

	^ monitor critical: [ 
		  | item |
		  monitor waitWhile: [ 
			  item := self nextOrNilSuchThat: aBlock.
			  item isNil ].
		  item ]
]

{ #category : #'*RemoteRunner' }
SharedQueue >> items: aCollection [
	"Set the receiver's items"

	monitor critical: 
		[ self assert: items isEmpty.
		items := aCollection asOrderedCollection ]
]
