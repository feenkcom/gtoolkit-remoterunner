Extension { #name : #TKTRunningTaskState }

{ #category : #'*RemoteRunner' }
TKTRunningTaskState >> gtRrAsElement [

	^ BrButton new
		  icon: BrGlamorousIcons greencircle;
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  label: 'running';
		  yourself
]
