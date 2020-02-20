import sng
cfg = sng.Config(
    epochs=50
)
sng.show_builtin_wordlists()
wordlist = sng.load_builtin_wordlist('gallic.txt')
gen = sng.Generator(wordlist=wordlist, config=cfg)
gen.fit()
print(gen.simulate(n=4))
gen.config.suffix = ' Ship'
print(gen.simulate(n=4))