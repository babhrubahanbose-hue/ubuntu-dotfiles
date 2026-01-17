import GObject from 'gi://GObject';
import Clutter from 'gi://Clutter';
import Cairo from 'gi://cairo';
import St from 'gi://St';

import { Drawing } from './drawing.js';
import { Frame } from './frame.js';
import { Vector } from './vector.js';

export const BorderSkin = GObject.registerClass(
  {},
  class BorderSkin extends St.DrawingArea {
    _init(settings = {}) {
      super._init();
      this.settings = settings;
    }

    redraw() {
      this.queue_repaint();
    }

    vfunc_repaint() {
      let ctx = this.get_context();
      let [width, height] = this.get_surface_size();

      ctx.setOperator(Cairo.Operator.CLEAR);
      ctx.paint();

      ctx.translate(width / 2, height / 2);
      ctx.setLineWidth(1);
      ctx.setLineCap(Cairo.LineCap.ROUND);
      ctx.setOperator(Cairo.Operator.SOURCE);

      // frame
      let thickness = this.settings.thickness || 0;
      let chamfer = thickness;

      // frame 1
      let innerThickness = this.settings.inner_thickness;
      let frame1 = new Frame(
        width - (thickness + thickness / 2) * 2,
        height - (thickness + thickness / 2) * 2,
        {
          top: [80, 280],
          bottom: [280, 80],
          left: [80, 80],
          right: [80, 80],
        },
        {
          leftTop: innerThickness + 4,
          rightTop: innerThickness + 4,
          rightBottom: innerThickness + 4,
          leftBottom: innerThickness + 4,
        }
      );

      // frame 2
      let frame2 = Frame.copy(frame1);
      frame2.grow(innerThickness);

      // frame 3
      let outerThickness = this.settings.outer_thickness;
      let frame3 = Frame.copy(frame2);
      frame3.setChamfers({
        leftTop: innerThickness + 4,
        rightTop: innerThickness + 4,
        rightBottom: innerThickness + 4,
        leftBottom: innerThickness + 4,
      });
      chamfer = chamfer * 0.5 + chamfer * this.settings.border_radius;
      frame3.segments.top[0] -= chamfer;
      frame3.segments.top[1] -= chamfer;
      frame3.segments.bottom[0] -= chamfer;
      frame3.segments.bottom[1] -= chamfer;
      frame3.segments.left[0] -= chamfer;
      frame3.segments.left[1] -= chamfer;
      frame3.segments.right[0] -= chamfer;
      frame3.segments.right[1] -= chamfer;
      ['top', 'bottom', 'left', 'right'].forEach((e) => {
        if (frame3.segments[e][0] < 0) {
          frame3.segments[e][0] = 0;
        }
        if (frame3.segments[e][1] < 0) {
          frame3.segments[e][1] = 0;
        }
      });
      frame3.grow(outerThickness);

      let frames = [frame1, frame2, frame3];
      Frame.adjustSegments(frames);
      frames.forEach((f) => {
        f.points();
        // this.draw_frame_points(ctx, f.points());
      });

      let clr = this.settings.color;
      let outerClr = this.settings.outer_outline_color || [0, 0, 0, 1];
      let innerClr = this.settings.inner_outline_color || [0, 0, 0, 1];

      let cornerFrames = Frame.cornerFrames([frame3, frame2, frame1], true);
      // let cornerFrames = Frame.cornerFrames([frame3, frame1]);
      cornerFrames.forEach((f) => {
        this.draw_frame_points(ctx, f, clr);
      });
      // let segmentFrames = Frame.segmentFrames([frame3, frame1]);
      let segmentFrames = Frame.segmentFrames([frame2, frame1]);
      segmentFrames.forEach((f) => {
        this.draw_frame_points(ctx, f, clr);
      });

      let outer = Frame.outerOutline(cornerFrames, segmentFrames, frames);
      this.draw_frame_points(ctx, outer, outerClr, 2);

      let inner = Frame.innerOutline(frames[0]);
      this.draw_frame_points(ctx, inner, innerClr, 2);

      ctx.$dispose();
    }

    draw_frame_points(ctx, points, clr, thickness = 0) {
      ctx.save();
      if (clr) {
        ctx.setSourceRGBA(clr[0], clr[1], clr[2], clr[3]);
      } else {
        ctx.setSourceRGBA(1, 0, 0, 1);
      }
      ctx.setLineWidth(thickness);

      for (let i = 0; i < points.length + 1; i++) {
        let p = points[i % points.length];
        if (i == 0) {
          ctx.moveTo(p.x, p.y);
        } else {
          ctx.lineTo(p.x, p.y);
        }
      }

      if (thickness > 0) {
        ctx.stroke();
      } else {
        ctx.fill();
      }
      ctx.restore();
    }
  }
);
