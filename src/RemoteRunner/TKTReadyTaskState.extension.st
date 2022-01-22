Extension { #name : #TKTReadyTaskState }

{ #category : #'*RemoteRunner' }
TKTReadyTaskState >> gtRrAsElement [

	^ BrButton new
		  icon: BrGlamorousIcons graycircle;
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  label: 'ready';
		  yourself
]
