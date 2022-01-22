Extension { #name : #TKTFinishedTaskState }

{ #category : #'*RemoteRunner' }
TKTFinishedTaskState >> gtRrAsElement [

	^ BrButton new
		  icon: BrGlamorousIcons graycircle;
		  aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			  - BrGlamorousButtonExteriorAptitude;
		  label: 'finished';
		  yourself
]
