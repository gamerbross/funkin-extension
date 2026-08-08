package runner.vslice;

typedef CommandResult = {
    wasSuccess:Bool,
    data:String
} 

typedef CompletionResult = {
    completions:Array<CompletionResultField>,
    fuzzyFieldLength:Int
}

typedef CompletionResultField = {
    field:String,
    field_type:String
}