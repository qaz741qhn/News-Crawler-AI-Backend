class CapabilitiesController < ApplicationController

  LANGUAGES_CAPABILITIES = {
    "python": ['data analysis', 'web scraping', 'automation', 'web request', 'algorithm', 'file operations', 'machine learning', 'data visualization', 'natural language processing', 'GUI creation'],
    "javascript": ['web request', 'DOM manipulation', 'event handling', 'asynchronous operations', 'local storage manipulation', 'ajax', 'fetch API', 'promises', 'async/await', 'react', 'angular', 'vue'],
    "java": ['multithreading', 'data structures', 'OOP concepts', 'file operations', 'database operations', 'servlets', 'spring framework', 'hibernate', 'JPA', 'JUnit'],
    "html": ['basic structure', 'form creation', 'table creation', 'image insertion', 'iframe usage', 'canvas', 'SVG', 'media', 'semantic HTML', 'HTML5 features'],
    "css": ['styling', 'animations', 'transformations', 'media queries', 'flexbox', 'grid', 'pseudo-classes', 'CSS variables', 'responsive design'],
    "sql": ['table creation', 'data manipulation', 'data querying', 'stored procedures', 'triggers', 'indexes', 'joins', 'subqueries', 'transactions', 'SQL functions'],
    "bash": ['file operations', 'process management', 'network operations', 'script execution', 'regular expressions', 'job scheduling', 'pipes and filters'],
    "powershell": ['script execution', 'task automation', 'file operations', 'system administration', 'remote management', 'pipes', 'error handling'],
    "r": ['statistical analysis', 'graphical representation', 'data manipulation', 'machine learning', 'data visualization', 'statistical tests', 'dplyr', 'ggplot2'],
    "matlab": ['matrix operations', 'plotting', 'algorithms', 'GUI creation', 'numerical methods', 'signal processing', 'image processing'],
    "perl": ['text processing', 'file operations', 'web scraping', 'system administration', 'regular expressions', 'network programming', 'object-oriented programming'],
    "ruby": ['web request', 'metaprogramming', 'file operations', 'database operations', 'blocks', 'procs and lambdas', 'modules', 'error handling'],
    "php": ['server-side scripting', 'database operations', 'file operations', 'error handling', 'OOP', 'sessions and cookies', 'file uploading', 'form handling and validation'],
    "go": ['concurrency', 'web request', 'file operations', 'testing', 'interfaces', 'slices', 'maps', 'error handling'],
    "scala": ['functional programming', 'OOP concepts', 'pattern matching', 'file operations', 'immutable data', 'lazy evaluation', 'concurrency', 'futures and promises'],
    "kotlin": ['null safety', 'coroutines', 'extension functions', 'data classes', 'lambda functions', 'collections', 'interoperability with Java'],
    "rust": ['memory safety', 'concurrency', 'error handling', 'pattern matching', 'macros', 'borrowing and ownership', 'lifetimes', 'traits'],
    "typescript": ['strong typing', 'interfaces', 'generics', 'asynchronous operations', 'namespaces', 'decorators', 'type inference', 'type alias'],
    "c": ['memory management', 'pointers', 'file operations', 'multi-threading', 'preprocessors', 'structures and unions', 'error handling'],
    "csharp": ['LINQ', 'async/await', 'events/delegates', 'file operations', 'generics', 'reflection', 'ASP.NET', 'Entity Framework'],
    "c_cpp": ['OOP concepts', 'memory management', 'multi-threading', 'file operations', 'template programming', 'error handling', 'STL'],
    "dart": ['asynchronous operations', 'generators', 'metadata', 'libraries and visibility', 'future and async', 'error handling', 'Flutter'],
    "swift": ['optionals', 'protocols', 'error handling', 'generics', 'closures', 'ARC', 'GCD', 'SwiftUI', 'Combine'],
    "elixir": ['processes', 'pattern matching', 'metaprogramming', 'error handling', 'concurrency', 'OTP', 'mix', 'plug'],
    "clojure": ['immutable data structures', 'functional programming', 'concurrency', 'macros', 'protocols', 'multi-methods', 'transducers', 'spec'],
    "haskell": ['pure functions', 'lazy evaluation', 'type inference', 'pattern matching', 'monads', 'functors', 'applicative functors', 'lenses'],
    "lua": ['tables', 'error handling', 'co-routines', 'metatables', 'modules', 'file I/O', 'patterns matching', 'game development'],
    "fsharp": ['immutability', 'type inference', 'pattern matching', 'computation expressions', 'async programming', 'units of measure', 'type providers', 'query expressions'],
    "groovy": ['closures', 'DSL support', 'metaprogramming', 'operators', 'Groovy SQL', 'XML and JSON handling', 'integration with Java'],
    "racket": ['macros', 'contracts', 'units', 'mixins', 'functional programming', 'data structures', 'lazy evaluation'],
    "ocaml": ['pattern matching', 'type inference', 'modules', 'functional programming', 'polymorphism', 'data abstraction', 'meta programming'],
    "julia": ['multiple dispatch', 'metaprogramming', 'concurrency', 'distributed computing', 'numerical accuracy', 'technical computing', 'interoperability', 'data visualization'],
    "vb": ['control structures', 'error handling', 'file operations', 'database operations', 'OOP', 'event handling', 'LINQ', 'ASP.NET'],
    "pascal": ['procedures and functions', 'file operations', 'modules', 'error handling', 'OOP', 'generics', 'concurrency', 'database connectivity'],
}

  def index
    language = params[:language].to_sym
    capabilities = LANGUAGES_CAPABILITIES[language]
    render json: { capabilities: capabilities }
  end
end
