Extension { #name : #GtRrRunnerMachineExamplesReport }

{ #category : #'*RemoteRunner' }
GtRrRunnerMachineExamplesReport >> machineTotalDefinedMemory [
	^ (GtAwsAmazonWebServices default ec2 instanceTypes 
			at: (self machineType )
			ifPresent: [ :anInstanceType | 
				anInstanceType totalMemory]
			ifAbsent: [ nil ])
]
