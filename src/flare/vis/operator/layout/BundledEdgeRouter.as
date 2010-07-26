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

package flare.vis.operator.layout
{

import flare.vis.data.DataSprite;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;
import flare.vis.operator.Operator;

import org.juicekit.animate.Transitioner;
import org.juicekit.util.Arrays;
import org.juicekit.util.Shapes;

/**
 * Layout that routes edges in a graph so that they form groups, reducing
 * clutter. This operator requires that a tree structure (for example, a
 * computed spanning tree) be defined over the graph. The class also sets
 * all edges' <code>shape</code> property to <code>Shapes.BSPLINE</code>
 * and can optionally compute <code>alpha</code> values to improve edge
 * visibility.
 *
 * <p>The algorithm uses the tree path between two nodes to define control
 * points for routing a b-spline curve. The technique is adapted from
 * Danny Holten's work on
 * <a href="http://www.win.tue.nl/~dholten/papers/bundles_infovis.pdf">
 * Hierarchical Edge Bundles</a>, InfoVis 2006.</p>
 */
public class BundledEdgeRouter extends Operator
{
  /** Determines how "tight" the edges are bundled. At 0, all edges are
   *  unbundled straight lines. At 1, the edges bundle together tightly.
   *  The default is 0.85. */
  public var bundling:Number = 0.85;
  /** Removes the shared ancestor along a node path. */
  public var removeSharedAncestor:Boolean = false;

  /**
   * Creates a new BundledEdgeRouter
   * @param bundling the tightness of edge bundles
   */
  public function BundledEdgeRouter(bundling:Number = 0.85,
                                    removeSharedAncestor:Boolean = false)
  {
    this.bundling = bundling;
    this.removeSharedAncestor = removeSharedAncestor;
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    t = (t == null ? Transitioner.DEFAULT : t);

    var u:NodeSprite, v:NodeSprite, pu:NodeSprite, pv:NodeSprite;
    var p1:Array = [], p2:Array = [];
    var d1:int, d2:int, o:Object;
    var ux:Number, uy:Number, dx:Number, dy:Number;

    // compute edge bundles
    for each (var e:EdgeSprite in visualization.data.edges) {
      u = e.source;
      p1.push(pu = u);
      d1 = u.depth;
      v = e.target;
      p2.push(pv = v);
      d2 = v.depth;

      // trace paths to the least common ancestor of u,v
      while (d1 > d2) {
        p1.push(pu = pu.parentNode);
        --d1;
      }
      while (d2 > d1) {
        p2.push(pv = pv.parentNode);
        --d2;
      }
      while (pu != pv) {
        p1.push(pu = pu.parentNode);
        p2.push(pv = pv.parentNode);
      }

      // collect b-spline control points
      var p:Array = t.$(e).points;
      if (p == null) {
        p = [];
      } else {
        Arrays.clear(p);
      }

      d1 = p1.length;
      d2 = p2.length;
      if ((d1 + d2) == 4 && d1 > 1 && d2 > 1) { // shared parent
        addPoint(p, p1[1], t);
      } else {
        var off:int = removeSharedAncestor ? 1 : 0;
        for (var i:int = 1; i < p1.length - off; ++i)
          addPoint(p, p1[i], t);
        for (i = p2.length - 1; --i >= 1;)
          addPoint(p, p2[i], t);
      }

      // set the bundling strength by adjusting control points
      var b:Number = bundling, ib:Number = 1 - b, N:int = p.length;
      if (b < 1) {
        o = t.$(u);
        ux = o.x;
        uy = o.y;
        o = t.$(v);
        dx = o.x;
        dy = o.y;
        dx = (dx - ux) / (N + 2);
        dy = (dy - uy) / (N + 2);

        for (i = 0; i < N; i += 2) {
          p[i] = b * p[i] + ib * (ux + (i + 2) * dx);
          p[i + 1] = b * p[i + 1] + ib * (uy + (i + 2) * dy);
        }
      }

      o = t.$(e);
      o.points = p;
      e.shape = Shapes.BSPLINE;

      // clean-up
      Arrays.clear(p1);
      Arrays.clear(p2);
    }
  }

  private static function addPoint(p:Array, d:DataSprite, t:Transitioner):void
  {
    var o:Object = t.$(d);
    p.push(o.x);
    p.push(o.y);
  }

} // end of class BundledEdgeRouter
}