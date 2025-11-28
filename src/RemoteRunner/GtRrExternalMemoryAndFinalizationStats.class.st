Class {
	#name : #GtRrExternalMemoryAndFinalizationStats,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'finalization',
		'pinInMemory',
		'newPinned',
		'gcallocate',
		'startTime',
		'memcpyPrimitive'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : 'RemoteRunner-Analysis'
}

{ #category : #'class initialization' }
GtRrExternalMemoryAndFinalizationStats class >> initialize [
	SessionManager default
		registerUserClassNamed: self name
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> install [
	"Update the relevant methods to collect the data"

	self uniqueInstance restart.

	self installFinalization.
	self installPinInMemory.
	self installGcallocate.
	self installNewPinned.
	self installMemcpyPrimitive.
	^ self uniqueInstance.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> installFinalization [
	"Update the relevant methods to collect the data"

	WeakArray class compile:
'finalizationProcess
	"The finalization process arranges to send mourn to each element of the VM''s finalization queue,
	 which is accessed via primitiveFetchMourner.  The VM signals FinalizationSemaphore whenever
	 the queue is non-empty.  This process loops, waiting on the semaphore, fetches the first element
	 of the queue and then spawns a process at a higher priority to actually send the mourn messages.
	 If an error occurs in the higher priority mourn loop process then this process will simply spawn
	 another process, hence ensuring that errors in finalization methods don''t break finalization.

	 In addition this process also runs the old finalization scheme, supporting clients of the older,
	 WeakRegistry based scheme.  Hopefully this will go away when all clients have moved over."
	<gtPharoPatch: #Pharo11>
	| throttle firstMourner |
	throttle := Semaphore new.
	[true] whileTrue: [FinalizationSemaphore wait; initSignals.
	 "Support the old scheme until things have changed over..."
	 self forPharo11OrNewer: []
	 	forPharo10: [ self doOldFinalization ].
	 [firstMourner := self primitiveFetchMourner.
	  firstMourner notNil] whileTrue:
		[MournLoopProcess := [
			GtRrExternalMemoryAndFinalizationStats uniqueInstance finalization startCycle.
			[ [ self mournLoopWith: firstMourner]
				on: Error
				fork: [ :ex | ex pass ] ]
					ensure: [ 
						GtRrExternalMemoryAndFinalizationStats uniqueInstance finalization endCycle.
						throttle signal ].
		] forkAt: Processor activePriority + 1.
		 throttle wait]]'
		classified: 'gt-runtime-stats-temporary'.
	WeakArray restartFinalizationProcess.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> installGcallocate [
	"Update the relevant methods to collect the data"

	ExternalAddress class compile:
'gcallocate: byteSize
	"Primitive. Allocate an object on the external heap.
	The external memory will be freed when i am garbage collected.
	BEWARE: there should be no copy of self, nor any pointer to a sub part..."

	| externalAddress |
	GtRrExternalMemoryAndFinalizationStats uniqueInstance gcallocate startCycle.
	externalAddress := self allocate: byteSize.
	self finalizationRegistry add: externalAddress.
	GtRrExternalMemoryAndFinalizationStats uniqueInstance gcallocate endCycle.
	^externalAddress'
		classified: 'gt-runtime-stats-temporary'.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> installMemcpyPrimitive [
	"Update the relevant methods to collect the data"

	ByteArray class compile:
'actualPrimitiveCopyFrom: src at: srcStart to: dest at: destStart size: size
	"Use memcpy() to copy data between ExternalAddresses and ByteArrays.
	starting at: is a 1-based index.
	No buffer overflow checks are done on ExternalAddresses."
	<primitive: ''primitiveCopyFromAtToAtSize''>
	^ self primitiveFailed'
		classified: 'gt-runtime-stats-temporary'.

	ByteArray class compile:
'primitiveCopyFrom: src at: srcStart to: dest at: destStart size: size
	"Use memcpy() to copy data between ExternalAddresses and ByteArrays.
	starting at: is a 1-based index.
	No buffer overflow checks are done on ExternalAddresses."
	| result |

	GtRrExternalMemoryAndFinalizationStats uniqueInstance memcpyPrimitive startCycle.
	result := self actualPrimitiveCopyFrom: src at: srcStart to: dest at: destStart size: size.
	GtRrExternalMemoryAndFinalizationStats uniqueInstance memcpyPrimitive endCycle.
	^ result.'
		classified: 'gt-runtime-stats-temporary'.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> installNewPinned [
	"Update the relevant methods to collect the data"

	Behavior compile:
'newPinned: sizeRequested
	| object |

	GtRrExternalMemoryAndFinalizationStats uniqueInstance newPinned startCycle.
	object := (self basicNewPinned: sizeRequested) initialize.
	GtRrExternalMemoryAndFinalizationStats uniqueInstance newPinned endCycle.
	^ object'
		classified: 'gt-runtime-stats-temporary'.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> installPinInMemory [
	"Update the relevant methods to collect the data"

	Object compile:
'pinInMemory
	"The VM''s garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved, which can make
	 it easier to pass objects out through the FFI.  Objects are unpinnned when created.
	 This method ensures an object is pinned, and answers whether it was already pinned."
	 | result |

	GtRrExternalMemoryAndFinalizationStats uniqueInstance pinInMemory startCycle.
	result := self setPinnedInMemory: true.
	GtRrExternalMemoryAndFinalizationStats uniqueInstance pinInMemory endCycle.
	^ result'
		classified: 'gt-runtime-stats-temporary'.
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> leJsonV4AttributeMapping [

	^ { 
		#finalization -> #finalization.
		#pinInMemory -> #pinInMemory.
		#newPinned -> #newPinned.
		#gcallocate -> #gcallocate.
		#startTime -> #startTime.
		#memcpyPrimitive -> #memcpyPrimitive. }
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats class >> leJsonV4Name [

	^ #gtExternalMemoryStats
]

{ #category : #'class initialization' }
GtRrExternalMemoryAndFinalizationStats class >> startUp: resuming [
	resuming ifTrue: [ self cleanUp ].
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> finalization [

	^ finalization
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> finalization: anObject [
	finalization := anObject
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> gcallocate [

	^ gcallocate
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> gcallocate: anObject [
	gcallocate := anObject
]

{ #category : #ui }
GtRrExternalMemoryAndFinalizationStats >> gtSummaryFor: aView [
	<gtView>

	^ aView text
		title: 'Summary';
		priority: 10;
		text: [ self reportString asRopedText glamorousCodeFont ];
		actionUpdateButton
]

{ #category : #ui }
GtRrExternalMemoryAndFinalizationStats >> gtTableFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Table';
		priority: 10;
		items: [ { finalization. gcallocate. newPinned. pinInMemory. memcpyPrimitive. } ];
		actionUpdateButton;
		column: 'Name' text: [ :entry | entry name ];
		column: 'Count' text: [ :entry | entry count asStringWithCommas ];
		column: 'Average (s)' text: [ :entry |
			entry average printShowingDecimalPlaces: 3 ];
		column: 'Slowest (s)' text: [ :entry | 
			entry slowest / 1000000.0 printShowingDecimalPlaces: 3 ];
		column: 'Cumulative (s)' text: [ :entry |
			entry seconds printShowingDecimalPlaces: 1 ];
		column: '%' text: [ :entry | 
			| elapsedTime elapsedSeconds percentage |
			elapsedTime := DateAndTime now - startTime.
			elapsedSeconds := elapsedTime asSeconds.
			percentage := elapsedSeconds > 0
				ifTrue: [ (entry seconds / elapsedSeconds) * 100.0 ]
				ifFalse: [ 0 ].
			percentage printShowingDecimalPlaces: 1 ]
]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats >> initialize [

	super initialize.
	self restart.
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> memcpyPrimitive [

	^ memcpyPrimitive
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> memcpyPrimitive: anObject [
	memcpyPrimitive := anObject
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> newPinned [

	^ newPinned
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> newPinned: anObject [
	newPinned := anObject
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> pinInMemory [

	^ pinInMemory
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> pinInMemory: anObject [
	pinInMemory := anObject
]

{ #category : #ui }
GtRrExternalMemoryAndFinalizationStats >> reportString [
	| elapsedTime |

	elapsedTime := DateAndTime now - startTime.
	^ String streamContents: [ :stream |
		stream
			<< 'Start time         : ';
				print: startTime; cr;
			<< 'Elapsed time       : ';
				print: elapsedTime; cr;
			cr;
			<< 'Finalization'; cr;
			<< '------------'; cr;
			<< (finalization reportStringFrom: startTime);
			cr;
			
			<< 'gcallocate'; cr;
			<< '----------'; cr;
			<< (gcallocate reportStringFrom: startTime);
			cr;

			<< 'newPinned'; cr;
			<< '---------'; cr;
			<< (newPinned reportStringFrom: startTime);
			cr;

			<< 'pinInMemory'; cr;
			<< '-----------'; cr;
			<< (pinInMemory reportStringFrom: startTime);
			cr;

			<< 'memcpyPrimitive'; cr;
			<< '---------------'; cr;
			<< (memcpyPrimitive reportStringFrom: startTime) ]

]

{ #category : #initialization }
GtRrExternalMemoryAndFinalizationStats >> restart [

	startTime := DateAndTime now.
	finalization := GtRrExternalMemoryAndFinalizationStatsEntry name: 'Finalisation'.
	pinInMemory := GtRrExternalMemoryAndFinalizationStatsEntry name: 'pinInMemory'.
	newPinned := GtRrExternalMemoryAndFinalizationStatsEntry name: 'newPinned'.
	gcallocate := GtRrExternalMemoryAndFinalizationStatsEntry name: 'gcallocate'.
	memcpyPrimitive := GtRrExternalMemoryAndFinalizationStatsEntry name: 'memcpyPrimitive'.
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> startTime [
	^ startTime
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> startTime: anObject [
	startTime := anObject
]

{ #category : #accessing }
GtRrExternalMemoryAndFinalizationStats >> totalSeconds [

	^ finalization seconds + pinInMemory seconds + newPinned seconds + gcallocate seconds + memcpyPrimitive seconds
]
