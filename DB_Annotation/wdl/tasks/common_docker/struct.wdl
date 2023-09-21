version 1.0

struct Parameter {
    Map[String, String] parameter
    Map[String, String] environment
    Map[String, String] software
    Map[String, String] database    
}

struct ModuleConfig {
    Map[String , Parameter] module
}

struct Groups{
    Map[String , Array[String]] groups
}