
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-yahoo_ads"
  spec.version       = "0.1.0"
  spec.authors       = ["ryota.yamada"]
  spec.summary       = "Yahoo Ads input plugin for Embulk"
  spec.description   = "Loads records from Yahoo Ads."
  spec.email         = ["ryota.yamada@principle-c.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/principle-c/embulk-input-yahoo_ads"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.0"
  spec.add_dependency "nokogiri", "~> 1.8.1"

  spec.add_development_dependency 'embulk', ['>= 0.8.30']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
