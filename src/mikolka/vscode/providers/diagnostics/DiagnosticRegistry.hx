package mikolka.vscode.providers.diagnostics;

import mikolka.config.MetadataParser;
import mikolka.config.MetadataParser.Metadata;
import haxe.io.Path;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Range;
import vscode.Diagnostic;
import vscode.DiagnosticCollection;
import vscode.TextDocument;

using StringTools;


/**
 * This registry contains all code for checking problems in a source files
 */
class DiagnosticRegistry extends DisposableProvider {
	/**
	 * This has all currently blacklisted classes from use
	 **/
	var importRegex:Map<EReg,String>;
	var problemsReporter:DiagnosticCollection;
	var config:Metadata;

	public function new(context:vscode.ExtensionContext) {
		problemsReporter = Vscode.languages.createDiagnosticCollection("Funkin");
		config = MetadataParser.readActiveMetadata();
		importRegex = MetadataParser.extractRegexRules(config);

		super(context,
			Vscode.workspace.onDidOpenTextDocument(requestImportCheck),
			Vscode.workspace.onDidSaveTextDocument(requestImportCheck)
		);
	}

	override function dispose() {
		super.dispose();
		problemsReporter.dispose();
	}
	
	/**
	 * Request a given file to be checked against any known blacklisted imports
	 * 
	 * If found, a new diagnostic data will be made internally to display them to the user
	 * @param file 
	 */
	public function requestImportCheck(file:TextDocument) {
		if (file.languageId != "haxe")
			return;
		var text = file.getText();
		var textMetadata = new SourceFileAnalyst(text);
		var warnings = new Array<Diagnostic>();

		for (importLine in textMetadata.importLines) {
			var warningMsg = findBlacklistClause(importLine.importName);
			if (warningMsg == null)
				continue;

			var range = new Range(importLine.position, 0, importLine.position, importLine.line.length);
			warnings.push(new Diagnostic(range, 'Blacklisted import: ${warningMsg}', Warning));
		}
		problemsReporter.set(file.uri, warnings);
	}

	function findBlacklistClause(importName:String):Null<String> {
		for (x in importRegex.keys()) {
			if (x.match(importName))
				return importRegex[x];
		}
		return null;
	}
}
