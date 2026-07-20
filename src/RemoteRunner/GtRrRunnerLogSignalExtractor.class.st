Class {
	#name : #GtRrRunnerLogSignalExtractor,
	#superclass : #Object,
	#instVars : [
		'inputFiles',
		'targetClass'
	],
	#category : #'RemoteRunner-JobStats'
}

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor class >> decodeStoredLog: aBase64String [
	"Decode a stored log from base64/gzip format back to the original string."
	^ aBase64String base64Decoded unzipped utf8Decoded
]

{ #category : #api }
GtRrRunnerLogSignalExtractor class >> extractFrom: inputFileReferences to: outputDirectory [
	"Convenience method to extract relevant signals from multiple logs
	and write each to a separate compressed file in the output directory."
	^ self new
		inputFiles: inputFileReferences;
		extractAndWriteTo: outputDirectory
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor class >> extractFrom: inputFileReferences toClass: aClass [
	"Convenience method to extract relevant signals from multiple logs
	and compile each as a class method on the target class."
	^ self new
		inputFiles: inputFileReferences;
		targetClass: aClass;
		extractAndCompileToClass
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor class >> signalsFromStoredLog: aBase64String [
	"Decode a stored log and parse it into signal objects."
	| logString signals |
	logString := self decodeStoredLog: aBase64String.
	signals := OrderedCollection new.
	logString lines do: [ :line |
		line trimBoth ifNotEmpty: [ :trimmed |
			| jsonDictionary signalClass signal |
			jsonDictionary := (NeoJSONReader on: trimmed readStream) next.
			signalClass := self environment classOrTraitNamed: (jsonDictionary at: 'signalClass') asSymbol.
			signalClass ifNotNil: [
				signal := signalClass fromGtJsonDictionary: jsonDictionary.
				signals add: signal ] ] ].
	^ signals
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor class >> storedLog: aBase64String toFileNamed: aFilename inFileSystem: aFileReference [
	"Decode a stored log and write it to a file in the given file system root.
	Answer the file reference to the created log file.
	
	Example usage:
		| memoryRoot logFile |
		memoryRoot := FileSystem memory root.
		logFile := GtRrLogSignalExtractor 
			storedLog: someBase64String 
			toFileNamed: 'test.log' 
			inFileSystem: memoryRoot.
	"
	| logString logFile |
	logString := self decodeStoredLog: aBase64String.
	logFile := aFileReference / aFilename.
	logFile writeStreamDo: [ :stream |
		stream nextPutAll: logString ].
	^ logFile
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor >> collectRelevantSignalsFrom: anAnalyzer [
	"Collect the relevant signals by reflectively calling all first...Signal 
	and last...Signal methods on the analyzer.
	Answer a Set of signals (to avoid duplicates)."
	| signals signalSelectors |
	signals := Set new.
	signalSelectors := GtRrRunnerLogTimingAnalyzer selectors select: [ :selector |
		((selector beginsWith: 'first') and: [ selector endsWith: 'Signal' ] )
		or: [ (selector beginsWith: 'last') and: [ selector endsWith: 'Signal' ] ] ].
	signalSelectors do: [ :selector |
		(anAnalyzer perform: selector) ifNotNil: [ :s | signals add: s ] ].
	^ signals asArray sorted: [ :a :b | a timestamp < b timestamp ]
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor >> compileReducedLog: extractedSignals forFile: inputFile [
	"Compile a class method on targetClass that returns the log content.
	The content is gzip compressed and base64 encoded for efficient storage.
	Answer the method selector."
	| logString compressedBase64 methodName methodSource |
	logString := self signalsToString: extractedSignals.
	compressedBase64 := logString utf8Encoded zipped base64Encoded.
	methodName := inputFile basenameWithoutExtension asValidSelector.
	methodSource := String streamContents: [ :stream |
		stream
			nextPutAll: methodName; cr;
			tab; nextPutAll: '"Auto-generated from: '''; nextPutAll: inputFile basename; nextPutAll: '"'; cr;
			tab; nextPutAll: '^ '''; nextPutAll: compressedBase64; nextPutAll: '''' ].
	targetClass classSide 
		compile: methodSource 
		classified: 'sample logs'.
	^ methodName asSymbol
]

{ #category : #extraction }
GtRrRunnerLogSignalExtractor >> extractAll [
	"Extract relevant signals from all input files.
	Answer a collection of associations mapping file -> extracted signals."
	^ inputFiles collect: [ :file |
		file -> (self extractSignalsFrom: file) ]
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor >> extractAndCompileToClass [
	"Extract signals from all input files and compile each as a class method
	on targetClass. Answer a collection of associations mapping input file -> selector."
	targetClass ifNil: [ self error: 'targetClass must be set before extracting' ].
	^ inputFiles collect: [ :inputFile |
		| extractedSignals selector |
		extractedSignals := self extractSignalsFrom: inputFile.
		selector := self compileReducedLog: extractedSignals forFile: inputFile.
		inputFile -> selector ]
]

{ #category : #api }
GtRrRunnerLogSignalExtractor >> extractAndWriteTo: outputDirectory [
	"Extract signals from all input files and write each to a separate reduced log file
	in the output directory. Files are compressed with gzip.
	Answer a collection of associations mapping input file -> output file."
	| results |
	outputDirectory ensureCreateDirectory.
	results := inputFiles collect: [ :inputFile |
		| extractedSignals outputFile |
		extractedSignals := self extractSignalsFrom: inputFile.
		outputFile := outputDirectory / (inputFile basename, '.gz').
		self writeReducedLog: extractedSignals to: outputFile.
		inputFile -> outputFile ].
	^ results
]

{ #category : #extraction }
GtRrRunnerLogSignalExtractor >> extractSignalsFrom: aFileReference [
	"Extract only the relevant signals from the given log file by using
	GtRrLogTimingAnalyzer to identify the specific signals needed for timing analysis.
	Answer an OrderedCollection of matching signals (without duplicates)."
	| analyzer relevantSignals |
	analyzer := GtRrRunnerLogTimingAnalyzer forFile: aFileReference.
	relevantSignals := self collectRelevantSignalsFrom: analyzer.
	^ relevantSignals
]

{ #category : #initialization }
GtRrRunnerLogSignalExtractor >> initialize [
	super initialize.
	inputFiles := OrderedCollection new
]

{ #category : #accessing }
GtRrRunnerLogSignalExtractor >> inputFiles [
	^ inputFiles
]

{ #category : #accessing }
GtRrRunnerLogSignalExtractor >> inputFiles: aCollectionOfFileReferences [
	inputFiles := aCollectionOfFileReferences asOrderedCollection
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor >> signalsToString: extractedSignals [
	"Serialize the extracted signals to a string in JSON format (one signal per line)."
	^ String streamContents: [ :stream |
		extractedSignals do: [ :signal |
			stream nextPutAll: (NeoJSONWriter toString: signal asGtJsonLogDictionary).
			stream cr ] ]
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor >> targetClass [
	^ targetClass
]

{ #category : #'as yet unclassified' }
GtRrRunnerLogSignalExtractor >> targetClass: aClass [
	targetClass := aClass
]

{ #category : #serialization }
GtRrRunnerLogSignalExtractor >> writeReducedLog: extractedSignals to: aFileReference [
	"Write the extracted signals to a file in JSON format (one signal per line)."
	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
		extractedSignals do: [ :signal |
			stream nextPutAll: (NeoJSONWriter toString: signal asGtJsonLogDictionary).
			stream cr ] ]
]
