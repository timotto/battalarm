import {Component, Input} from '@angular/core';
import {Image} from "../model";
import {ImageViewerService} from "../image-viewer.service";

@Component({
  selector: 'app-image-thumbnail',
  standalone: true,
  imports: [],
  templateUrl: './image-thumbnail.component.html',
  styleUrl: './image-thumbnail.component.scss'
})
export class ImageThumbnailComponent {
  @Input({required: true})
  src?: string

  @Input({required: true})
  srcThumb?: string

  @Input({required: true})
  alt?: string

  constructor(protected readonly service: ImageViewerService) {
  }

  protected click() {
    const image = this.asImage()
    if (!image) return
    this.service.showFullscreen(image)
  }

  private asImage(): Image | undefined {
    if (!this.src || !this.srcThumb || !this.alt) return undefined
    return {
      src: this.src,
      srcThumb: this.srcThumb,
      alt: this.alt,
    }
  }
}
