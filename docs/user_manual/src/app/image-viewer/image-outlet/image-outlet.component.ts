import {Component} from '@angular/core';
import {ImageViewerService} from "../image-viewer.service";
import {Image} from "../model";
import {MatIconButton} from "@angular/material/button";
import {MatIcon} from "@angular/material/icon";

@Component({
  selector: 'app-image-outlet',
  standalone: true,
  imports: [
    MatIconButton,
    MatIcon
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
