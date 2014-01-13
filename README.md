tdiff
=====

A tree differencing library for javascript, implementing the
[Robust Tree Edit Distance (RTED) Algorithm by M. Pawlik and N. Augsten][0].

Also in this repository is a webapp for generating difference visualizations
between javascript sources as [Parser API AST][1], which--by operating at the
syntax level--should be able to more accurately identify changed program elements
than a text-based differencing algorithm such as GNU `diff`.

[0]: http://www.inf.unibz.it/dis/projects/tree-edit-distance/tree-edit-distance.php
[1]: https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API
