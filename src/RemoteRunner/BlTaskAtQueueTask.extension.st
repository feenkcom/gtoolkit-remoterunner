Extension { #name : #BlTaskAtQueueTask }

{ #category : #'*RemoteRunner' }
BlTaskAtQueueTask >> gtRrAsElement [

	^ BlElement new
		  layout: BlLinearLayout horizontal;
		  constraintsDo: [ :c | 
			  c horizontal fitContent.
			  c vertical fitContent ];
		  addChild: (BrLabel new
				   aptitude: BrGlamorousLabelAptitude;
				   text: scheduledTime asString;
				   yourself)
		  as: #time;
		  addChild: (BrLabel new
				   aptitude: BrGlamorousLabelAptitude;
				   text: valuable asString;
				   yourself)
		  as: #valuable;
		  yourself
]
