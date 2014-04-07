require! express

express!
  ..use \/tdiff express.static __dirname + '/'
  # fetch actual files, kinda dangerous.
  ..use \/file express.static '/'
  ..listen 7416

console.log 'listening on 7416'
