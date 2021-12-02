Class {
	#name : #GtDtsTestScheduler,
	#superclass : #Object,
	#instVars : [
		'dtsManager',
		'compoundPromise'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #initialization }
GtDtsTestScheduler >> initialize [

	super initialize.
	compoundPromise := AsyncFulfilledPromise new.
]

{ #category : #schedulling }
GtDtsTestScheduler >> schedule: aGtDtsJob [
	| promise |

	aGtDtsJob allTests do: [ :test |
		promise := dtsManager submit: 
			(GtDtsTestTask tests: { test key -> { test value } } asDictionary).
		promise 
			then: [ :aCollection | aGtDtsJob addResults: aCollection ]
			otherwise: [ self halt ] ].
]
