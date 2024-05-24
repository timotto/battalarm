import {Component} from '@angular/core';
import {ImageViewerService} from "../image-viewer.service";
import {Image} from "../model";
import {ImageFullscreenComponent} from "../image-fullscreen/image-fullscreen.component";

@Component({
  selector: 'app-image-outlet',
  standalone: true,
  imports: [
    ImageFullscreenComponent
  ],
  templateUrl: './image-outlet.component.html',
  styleUrl: './image-outlet.component.scss'
})
export class ImageOutletComponent {
  protected image?: Image = undefined

  constructor(service: ImageViewerService) {
    service.fullscreenImages
      .subscribe(image => this.onShowFullscreen(image))
  }

  protected close() {
    this.image = undefined
  }

  private onShowFullscreen(image: Image) {
    this.image = image
  }
}
