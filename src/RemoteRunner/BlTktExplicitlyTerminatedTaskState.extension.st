Extension { #name : #BlTktExplicitlyTerminatedTaskState }

{ #category : #'*RemoteRunner' }
BlTktExplicitlyTerminatedTaskState >> gtRrAsElement [

	^ BrButton new
		  icon: BrGlamorousIcons redcircle;
		  aptitude: BrGlamorousButtonWithLabelAndIconAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  label: 'terminated';
		  yourself
]
