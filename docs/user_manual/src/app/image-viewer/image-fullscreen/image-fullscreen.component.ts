import {Component, EventEmitter, Input, Output} from '@angular/core';
import {Image} from "../model";
import {MatIcon} from "@angular/material/icon";
import {MatIconButton} from "@angular/material/button";

@Component({
  selector: 'app-image-fullscreen',
  standalone: true,
  imports: [
    MatIconButton,
    MatIcon
  ],
  templateUrl: './image-fullscreen.component.html',
  styleUrl: './image-fullscreen.component.scss'
})
export class ImageFullscreenComponent {
  @Input({required: true})
  image?: Image

  @Output()
  onClose = new EventEmitter()

  protected close() {
    this.onClose.next(true)
  }
}
