Extension { #name : #SequenceableCollection }

{ #category : #'*RemoteRunner' }
SequenceableCollection >> reverseSelect: selectBock thenDo: aBlock [
	"Iterate over the receiver in reverse order, evaluating aBlock for those entries where selectBlock evaluates to true"
	"(Array streamContents: [:stream | #(1 2 3 4) reverseSelect: [:each | each > 2 ] thenDo: [:each | stream nextPut: each + 10]]) >>> #(14 13)"
	
	| each |
	self size to: 1 by: -1 do: [ :index |
		(selectBock value: (each := self at: index))
			ifTrue: [ aBlock value: each ]].
]
