import { Vector } from './vector.js';

export const Frame = class {
    constructor(width = 100, height = 100, segments = {}, chamfers = {}) {
      this.setSegments(segments);
      this.setChamfers(chamfers);
      this.resize(width, height);
    }
  
    static copy(frame) {
      return new Frame(frame.width, frame.height, frame.segments);
    }
  
    setSegments(segments) {
      this.segments = {};
      ['left', 'right', 'top', 'bottom'].forEach((k) => {
        this.segments[k] = { ...(segments[k] || [0, 0]) };
      });
    }
  
    static adjustSegments(frames) {
      let edges = ['top', 'left', 'bottom', 'right'];
      let adjustments = { top: 0, left: 0, bottom: 0, right: 0 };
      frames.forEach((f) => {
        edges.forEach((k) => {
          if (f.segments[k][0] + f.segments[k][1] > f.width) {
            let adjust = f.segments[k][0] + f.segments[k][1] - f.width;
            adjustments[k] = adjustments[k] < adjust ? adjust : adjustments[k];
          }
        });
      });
      frames.forEach((f) => {
        edges.forEach((k) => {
          if (adjustments[k] > 0) {
            let t = f.segments[k][0] + f.segments[k][1];
            adjustments[k] += 8;
            f.segments[k][0] -= (adjustments[k] * f.segments[k][0]) / t;
            f.segments[k][1] -= (adjustments[k] * f.segments[k][1]) / t;
          }
        });
      });
    }
  
    setChamfers(chamfers) {
      this.chamfers = [0, 0, 0, 0];
      let idx = 0;
      ['leftTop', 'rightTop', 'rightBottom', 'leftBottom'].forEach((k) => {
        this.chamfers[idx++] = chamfers[k] || 0;
      });
    }
  
    resize(width, height) {
      this.width = width;
      this.height = height;
      this.rebuildPoints();
    }
  
    grow(thickness) {
      if (this.segments) {
        Object.keys(this.segments).forEach((k) => {
          if (this.segments[k]) {
            this.segments[k][0] += thickness;
            this.segments[k][1] += thickness;
          }
        });
      }
      this.resize(this.width + thickness * 2, this.height + thickness * 2);
    }
  
    static hideEdges(frames, edges = {}) {
      for(let i=1; i<frames.length; i++) {
          if (edges.left) {
              frames[i].leftTop.x = frames[0].leftTop.x;
              frames[i].leftBottom.x = frames[0].leftBottom.x;
          }
          if (edges.right) {
              frames[i].rightTop.x = frames[0].rightTop.x;
              frames[i].rightBottom.x = frames[0].rightBottom.x;
          }
          if (edges.top) {
              frames[i].leftTop.y = frames[0].leftTop.y;
              frames[i].rightTop.y = frames[0].rightTop.y;
          }
          if (edges.bottom) {
              frames[i].leftBottom.y = frames[0].leftBottom.y;
              frames[i].rightBottom.y = frames[0].rightBottom.y;
          }
      }
    }
  
    rebuildPoints() {
      this.leftTop = new Vector([-this.width / 2, -this.height / 2]);
      this.rightTop = this.leftTop.add(new Vector([this.width, 0]));
      this.rightBottom = this.rightTop.add(new Vector([0, this.height]));
      this.leftBottom = new Vector([this.leftTop.x, this.rightBottom.y]);
      return this.cornerPoints();
    }
  
    cornerPoints() {
      let points = [
        this.leftTop,
        this.rightTop,
        this.rightBottom,
        this.leftBottom,
      ];
      let idx = 0;
      points.forEach((p) => {
        p.rounded = true;
        p.corner = true;
        p.chamfer = this.chamfers[idx++];
      });
      return points;
    }
  
    points() {
      if (this._points) return this._points;
      let points = [];
      points.push(this.leftTop);
      // this.segments.top = this.segments.top || [0, 0];
      points.push(this.leftTop.add(new Vector([this.segments.top[0], 0])));
      points.push(this.rightTop.subtract(new Vector([this.segments.top[1], 0])));
      points.push(this.rightTop);
      // this.segments.right = this.segments.right || [0, 0];
      points.push(this.rightTop.add(new Vector([0, this.segments.right[0]])));
      points.push(
        this.rightBottom.subtract(new Vector([0, this.segments.right[1]]))
      );
      points.push(this.rightBottom);
      // this.segments.bottom = this.segments.bottom || [0, 0];
      points.push(
        this.rightBottom.subtract(new Vector([this.segments.bottom[1], 0]))
      );
      points.push(this.leftBottom.add(new Vector([this.segments.bottom[0], 0])));
      points.push(this.leftBottom);
      // this.segments.left = this.segments.left || [0, 0];
      points.push(
        this.leftBottom.subtract(new Vector([0, this.segments.left[1]]))
      );
      points.push(this.leftTop.add(new Vector([0, this.segments.left[0]])));
  
      // link list the points
      for (let i = 0; i < points.length; i++) {
        let pp = points[(i - 1 + points.length) % points.length];
        let p = points[i];
        let np = points[(i + 1) % points.length];
        p.prev = pp;
        p.next = np;
        p.frame = this;
      }
  
      this._points = points;
      return points;
    }
  
    static segmentFrames(frames) {
      let result = [];
      // top
      {
        let points = [];
        points.push(frames[0].leftTop.next);
        points.push(frames[0].rightTop.prev);
        points.push(frames[1].rightTop.prev);
        points.push(frames[1].leftTop.next);
        result.push(points);
      }
      // left
      {
        let points = [];
        points.push(frames[0].rightTop.next);
        points.push(frames[0].rightBottom.prev);
        points.push(frames[1].rightBottom.prev);
        points.push(frames[1].rightTop.next);
        result.push(points);
      }
      // bottom
      {
        let points = [];
        points.push(frames[0].rightBottom.next);
        points.push(frames[0].leftBottom.prev);
        points.push(frames[1].leftBottom.prev);
        points.push(frames[1].rightBottom.next);
        result.push(points);
      }
  
      // left
      {
        let points = [];
        points.push(frames[0].leftBottom.next);
        points.push(frames[0].leftTop.prev);
        points.push(frames[1].leftTop.prev);
        points.push(frames[1].leftBottom.next);
        result.push(points);
      }
      return result;
    }
  
    static cornerFrames(frames, roundedCorner = false) {
      let result = [];
      // left top
      {
        let points = [];
        points.push(frames[1].leftTop.prev);
        points.push(frames[0].leftTop.prev);
        points.push(frames[0].leftTop);
        points.push(frames[0].leftTop.next);
        points.push(frames[1].leftTop.next);
        if (frames[2]) {
          points.push(frames[2].leftTop.next);
          points.push(frames[2].leftTop);
          points.push(frames[2].leftTop.prev);
        } else {
          points.push(frames[1].leftTop);
        }
        result.push(points);
      }
      // right top
      {
        let points = [];
        points.push(frames[1].rightTop.prev);
        points.push(frames[0].rightTop.prev);
        points.push(frames[0].rightTop);
        points.push(frames[0].rightTop.next);
        points.push(frames[1].rightTop.next);
        if (frames[2]) {
          points.push(frames[2].rightTop.next);
          points.push(frames[2].rightTop);
          points.push(frames[2].rightTop.prev);
        } else {
          points.push(frames[1].rightTop);
        }
        result.push(points);
      }
      // right bottom
      {
        let points = [];
        points.push(frames[1].rightBottom.prev);
        points.push(frames[0].rightBottom.prev);
        points.push(frames[0].rightBottom);
        points.push(frames[0].rightBottom.next);
        points.push(frames[1].rightBottom.next);
        if (frames[2]) {
          points.push(frames[2].rightBottom.next);
          points.push(frames[2].rightBottom);
          points.push(frames[2].rightBottom.prev);
        } else {
          points.push(frames[1].rightBottom);
        }
        result.push(points);
      }
      // left bottom -- todo this is counter-clockwise
      {
        let points = [];
        points.push(frames[1].leftBottom.prev);
        points.push(frames[0].leftBottom.prev);
        points.push(frames[0].leftBottom);
        points.push(frames[0].leftBottom.next);
        points.push(frames[1].leftBottom.next);
        if (frames[2]) {
          points.push(frames[2].leftBottom.next);
          points.push(frames[2].leftBottom);
          points.push(frames[2].leftBottom.prev);
        } else {
          points.push(frames[1].leftBottom);
        }
        result.push(points);
      }
  
      if (roundedCorner > 0) {
        let resultChamfered = [];
        result.forEach((r) => {
          let points = this.addChamfer(r, frames);
          resultChamfered.push(points);
        });
        result = resultChamfered;
      }
      return result;
    }
  
    static addChamfer(r, frames) {
      // link list the points
      for (let i = 0; i < r.length; i++) {
        let pp = r[(i - 1 + r.length) % r.length];
        let p = r[i];
        let np = r[(i + 1) % r.length];
        p.fprev = pp;
        p.fnext = np;
      }
  
      let points = [];
      r.forEach((p) => {
        if (
          p.corner &&
          (p.frame == frames[0] || p.frame == frames[frames.length - 1])
        ) {
          let offset = p.chamfer;
          let pp = p.fprev.subtract(p).normalize().multiplyScalar(offset).add(p);
          let pn = p.fnext.subtract(p).normalize().multiplyScalar(offset).add(p);
          points.push(pp);
          if (pp.rounded) {
            pp.mid = p;
          }
          points.push(pn);
        } else {
          points.push(p);
        }
      });
  
      return points;
    }
  
    static outerOutline(cornerFrames, segments, frames) {
      let points = [];
      let sets = [
        cornerFrames[0],
        segments[0],
        cornerFrames[1],
        segments[1],
        cornerFrames[2],
        segments[2],
        cornerFrames[3],
        segments[3],
      ];
  
      sets.forEach((r) => {
        for (let i = 0; i < r.length; i++) {
          let p = r[i];
          if (p.frame == frames[0]) {
            break;
          }
          points.push(p);
        }
      });
  
      return points;
    }
  
    static innerOutline(frame) {
      return Frame.addChamfer(frame.points(), [frame]);
    }
  };
  