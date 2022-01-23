Extension { #name : #BlTktExplicitlyTerminatedTaskState }

{ #category : #'*RemoteRunner' }
BlTktExplicitlyTerminatedTaskState >> gtRrAsElement [

	^ BrButton new
		  icon: BrGlamorousIcons redcircle;
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  label: 'terminated';
		  yourself
]
