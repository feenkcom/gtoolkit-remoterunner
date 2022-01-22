Extension { #name : #TKTCancelledTaskState }

{ #category : #'*RemoteRunner' }
TKTCancelledTaskState >> gtRrAsElement [

	^ BrButton new
		  icon: BrGlamorousIcons redcircle;
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  label: 'cancelled';
		  yourself
]
