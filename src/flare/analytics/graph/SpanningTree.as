/*
 * Copyright (c) 2007-2010 Regents of the University of California.
 *   All rights reserved.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 *   3.  Neither the name of the University nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *   ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 *   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *   SUCH DAMAGE.
 */

package flare.analytics.graph
{
import flare.vis.Visualization;
import flare.vis.data.NodeSprite;
import flare.vis.data.TreeBuilder;
import flare.vis.operator.IOperator;
import flare.vis.operator.Operator;

import org.juicekit.animate.Transitioner;

/**
 * Calculates a spanning tree for a graph structure. This operator can
 * create spanning trees by breadth-first search, depth-first search, or by
 * computing a minimum spanning tree. The default is to find a minimum
 * spanning tree, which in turn defaults to breadth-first search if no edge
 * weight function is provided.
 *
 * <p>This class can annotate graph edges as belonging to the spanning tree
 * (done if the <code>annotateEdges</code> property is true), and can
 * construct a <code>Tree</code> instance (done if the
 * <code>buildTree</code> property is true). Generated <code>Tree</code>
 * instances are stored in the <code>tree</code> property. Generated trees
 * contain the original nodes and edges in the input graph, and any
 * previous parent or child links for input nodes will be cleared and
 * overwritten.</p>
 *
 * <p>This class extends the TreeBuilder class to also function as an
 * operator that can be added to a visualization's operator list.</p>
 */
public class SpanningTree extends TreeBuilder implements IOperator
{
  private var _vis:Visualization;
  private var _enabled:Boolean;

  /** @inheritDoc */
  public function get visualization():Visualization {
    return _vis;
  }

  public function set visualization(v:Visualization):void {
    _vis = v;
    setup();
  }

  /** @inheritDoc */
  public function get enabled():Boolean {
    return _enabled;
  }

  public function set enabled(b:Boolean):void {
    _enabled = b;
  }

  /** @inheritDoc */
  public function set parameters(params:Object):void
  {
    Operator.applyParameters(this, params);
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new SpanningTree operator
   * @param policy the spanning tree creation policy. The default is
   *  <code>SpanningTree.MINIMUM_SPAN</code>
   * @param buildTree if true, this operator will build a new
   *  <code>Tree</code> instance containing the spanning tree
   * @param annotateEdges if true, this operator will annotate the
   *  edges of the original graph as belonging to the spanning tree
   * @param root the root node from which to compute the spanning tree
   * @param edgeWeight the edge weight values. This can either be a
   *  <code>Function</code> that returns weight values or a
   *  <code>String</code> providing the name of a property to look up on
   *  <code>EdgeSprite</code> instances.
   */
  public function SpanningTree(policy:String = null,
                               buildTree:Boolean = false, annotateEdges:Boolean = true,
                               root:NodeSprite = null, edgeWeight:* = null)
  {
    super(policy, buildTree, annotateEdges, root, edgeWeight);
  }

  /** @inheritDoc */
  public function operate(t:Transitioner = null):void
  {
    super.calculate(visualization.data, root);
  }

  /** @inheritDoc */
  public function setup():void
  {
    // for subclasses
  }

  // -- MXML ------------------------------------------------------------

  /** @private */
  public function initialized(document:Object, id:String):void
  {
    // do nothing
  }

} // end of class SpanningTree
}