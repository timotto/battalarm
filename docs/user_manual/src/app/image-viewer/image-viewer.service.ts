import { Injectable } from '@angular/core';
import {Image} from "./model";
import {Observable, Subject} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class ImageViewerService {

  private _fullscreen = new Subject<Image>()

  constructor() { }

  public showFullscreen(image: Image) {
    this._fullscreen.next(image)
  }

  public get fullscreenImages(): Observable<Image> {
    return this._fullscreen.asObservable()
  }
}
