import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ImageFullscreenComponent } from './image-fullscreen.component';

describe('ImageFullscreenComponent', () => {
  let component: ImageFullscreenComponent;
  let fixture: ComponentFixture<ImageFullscreenComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ImageFullscreenComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ImageFullscreenComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
