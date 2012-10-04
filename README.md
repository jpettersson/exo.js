exo.js
======

Exo is a small JS library that brings a bunch of classes and workflows to make it fun and easy to build heavily animated realtime JS apps. The library is a perfect exoskeleton for projects using [Spine.js](http://spinejs.com/) or [Backbone.js](http://backbonejs.org/).

*The library and the docs are currently under heavy development.*

CoffeeScript <3
------------
The library, test specs and the examples are all written in [CoffeeScript](http://coffeescript.org/).

Exo.StateMachine
----------------
The core of the Exo lib is a FSM (Finite State Machine) implementation. This class is not commonly used directly, but when it is it can be configured in all the ways you'd expect an FSM to allow.

Exo.Node
--------
The Exo Node is the real workhorse of the Exo lib. The Node is very oppionated and assumes that all your UI components can be broken down into hierarchies of little machines with the following properties: 

A node has an internal FSM with two states and two transitions: 

	[Deactivated] activate -> [Activated]
	[Activated] deactivate -> [Deactivated]

Nodes can be connected to each other as parent -> children, effectively creating a directed graph of state machines (and state control). Take a look at the VisualNode example to experience why it's useful. 

This model has proven to be extremely robust and powerful: enabling rapid prototyping and clean code.

Exo.Spine.Controller
--------------------
This class extends the Spine.Controller and infuses it will all the functionality of the Exo.Node. Instances of Exo.Node and Exo.Spine.Controllers are completely compatible.

Examples
--------
Two examples have been provided to showcase the core features of Exo while using it together with Spine.js. To run the examples you need to init & update the git submodules in order to get the correct Spine.js source.

``git submodule init``	
``git submodule update``

Tests
-----
Using Jasmine.

License
-------
Copyright (c) 2012 Jonathan Pettersson (jonathan@spacetofu.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.